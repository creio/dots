# -*- Mode: Python; indent-tabs-mode: t; python-indent: 4; tab-width: 4 -*-
import os
from gi.repository import Gtk, Gdk
from copy import deepcopy

import acyls
import acyls.lib.iconchanger as iconchanger
import acyls.lib.gradient as gradient
from acyls.lib.icongroup import IconGroupCollector
from acyls.lib.filters import FilterCollector
from acyls.lib.guisupport import hex_from_rgba, FileChooser
from acyls.lib.multithread import multithread


class ColorPage:
	"""Colors tab"""
	def __init__(self, database, config):
		self.database = database
		self.config = config

		# Read icon size settins from config
		self.PREVIEW_ICON_SIZE = self.config.getint("PreviewSize", "single")

		# Load icon groups from config file
		self.icongroups = IconGroupCollector(self.config)

		# Build griadient object
		self.gradient = gradient.Gradient()

		# Load filters from certain directory
		self.filters = FilterCollector(acyls.dirs['filters'])
		self.filters.connect_signal(self.filter_refresh)

		# File dialog
		self.filechooser = FileChooser(acyls.dirs['user'], "custom.acyl")

		# Load GUI
		self.signals = dict()
		self.builder = Gtk.Builder()
		self.builder.add_from_file(os.path.join(acyls.dirs['gui'], "colors.glade"))

		gui_elements = (
			'colorbox', 'icongroup_combo', 'custom_icons_treeview', 'colorlist_treeview', 'gradient_combo',
			'filter_group_combo', 'filters_combo', 'direction_treeview', 'handoffset_switch', 'filters_combo',
			'colorlist_treeview_selection', 'offset_scale', 'color_selector', 'offset_scale', 'render_button',
			'preview_icon', 'filter_settings_button',
		)
		self.gui = {element: self.builder.get_object(element) for element in gui_elements}

		# Build stores
		self.build_data_stores()

		# Database setup
		self.build_data_hadlers()

		# Toolbar buttnons hanlers
		self.bhandlers = dict()
		self.bhandlers['add_color_toolbutton'] = self.on_add_color_button_click
		self.bhandlers['remove_color_toolbutton'] = self.on_remove_color_button_click
		self.bhandlers['copy_color_toolbutton'] = self.on_copy_settings_button_click
		self.bhandlers['paste_color_toolbutton'] = self.on_paste_settings_button_click
		self.bhandlers['save_settings_toolbutton'] = self.on_save_settings_button_click
		self.bhandlers['load_settings_toolbutton'] = self.on_load_settings_button_click
		self.bhandlers['reset_settings_toolbutton'] = self.on_reset_settings_button_click

		# Mainpage buttnons hanlers
		self.mhandlers = dict()
		self.mhandlers['refresh_button'] = self.on_refresh_click
		self.mhandlers['apply_button'] = self.on_apply_click

		# Init vars
		self.color_selected = None
		self.rtr = False
		self.init_confirmed = False
		self.state_buffer = {}

		# Fill up gui
		for name in self.icongroups.names:
			self.gui['icongroup_combo'].append_text(name)

		for tag in sorted(gradient.GRADIENT_PROFILES):
			self.gui['gradient_combo'].append_text(tag)

		for group in self.filters.groupnames:
			self.gui['filter_group_combo'].append_text(group)

		# connect signals
		self.connect_signals()
		self.gui['icongroup_combo'].set_active(0)

		# restore GUI elements state from last session
		self.gui['render_button'].set_active(self.config.getboolean("Settings", "autorender"))

		self.init_confirmed = True

	# Init functions
	def connect_signals(self):
		"""Connect GUI handlers"""
		self.signals['colorlist'] = self.gui['colorlist_treeview_selection'].connect(
			"changed", self.on_color_selection_changed
		)
		self.signals['handoffset_switch'] = self.gui['handoffset_switch'].connect(
			"notify::active", self.on_handoffset_toggled
		)
		self.signals['colorlist_del'] = self.store['colorlist'].connect(
			"row-deleted", self.on_colorlist_structure_changed
		)
		self.signals['colorlist_add'] = self.store['colorlist'].connect(
			"row-inserted", self.on_colorlist_structure_changed
		)
		self.signals['color_selector'] = self.gui['color_selector'].connect(
			"color_changed", self.on_color_change
		)

		self.gui['icongroup_combo'].connect("changed", self.on_icongroup_combo_changed)
		self.gui['filter_group_combo'].connect("changed", self.on_filter_group_combo_changed)
		self.gui['filters_combo'].connect("changed", self.on_filter_combo_changed)
		self.gui['offset_scale'].connect("value_changed", self.on_offset_value_changed)
		self.gui['gradient_combo'].connect("changed", self.on_gradient_type_switched)
		self.gui['render_button'].connect("toggled", self.on_render_toggled)
		self.gui['filter_settings_button'].connect("clicked", self.on_filter_settings_click)

	def build_data_stores(self):
		"""Build stores for GUI dataviews"""
		self.store = dict()

		# custom icons
		self.ied = {'Name': 0, 'State': 1}
		self.store['custom_icons'] = Gtk.ListStore(str, bool)
		self.store['custom_icons'].append(["Simple Icon Group", False])

		renderer_toggle = Gtk.CellRendererToggle()
		renderer_toggle.connect("toggled", self.on_custom_icon_toggled)

		self.gui['custom_icons_treeview'].append_column(Gtk.TreeViewColumn("Name", Gtk.CellRendererText(), text=0))
		self.gui['custom_icons_treeview'].append_column(Gtk.TreeViewColumn("State", renderer_toggle, active=1))
		self.gui['custom_icons_treeview'].set_model(self.store['custom_icons'])

		# color list
		self.ced = {'Color': 0, 'Alpha': 1, 'Offset': 2, 'RGBA': 3}
		colorstore_visible_keys = [k for k in self.ced.keys() if k != 'RGBA']

		self.store['colorlist'] = Gtk.ListStore(str, float, int, str)
		for key in sorted(colorstore_visible_keys, key=lambda k: self.ced[k]):
			self.gui['colorlist_treeview'].append_column(
				Gtk.TreeViewColumn(key, Gtk.CellRendererText(), text=self.ced[key])
			)
		self.gui['colorlist_treeview'].set_model(self.store['colorlist'])

		# gradient direction
		self.ded = {'Coord': 0, 'Value': 1}
		self.store['direction'] = Gtk.ListStore(str, int)
		self.gui['renderer_spin'] = Gtk.CellRendererSpin(editable=True, adjustment=Gtk.Adjustment(0, 0, 100, 5, 0, 0))
		self.signals['direction_edited'] = self.gui['renderer_spin'].connect("edited", self.on_direction_edited)

		self.gui['direction_treeview'].append_column(Gtk.TreeViewColumn("Coord", Gtk.CellRendererText(), text=0))
		self.gui['direction_treeview'].append_column(Gtk.TreeViewColumn("Value", self.gui['renderer_spin'], text=1))
		self.gui['direction_treeview'].set_model(self.store['direction'])

	def build_data_hadlers(self):
		"""GUI state from/to database"""

		# Read GUI setting from database
		def read_colors(dump):
			# Fix this
			with self.gui['colorlist_treeview_selection'].handler_block(self.signals['colorlist']):
				with self.store['colorlist'].handler_block(self.signals['colorlist_add']):
					with self.store['colorlist'].handler_block(self.signals['colorlist_del']):
						self.store['colorlist'].clear()
						for color in dump['colors']:
							self.store['colorlist'].append(color)

			with self.gui['color_selector'].handler_block(self.signals['color_selector']):
				self.on_colorlist_structure_changed()

		def read_gradient_type(dump):
			self.gui['gradient_combo'].set_active(gradient.GRADIENT_PROFILES[dump['gradtype']]['index'])

		def read_filter_name(dump):
			filter_ = dump['filter']
			self.gui['filter_group_combo'].set_active(self.filters.get_group_index(filter_))
			filter_index = self.filters.names.index(filter_) if filter_ in self.filters.names else 0
			self.gui['filters_combo'].set_active(filter_index)

		def read_gradient_settings(dump):
			with self.gui['renderer_spin'].handler_block(self.signals['direction_edited']):
				self.store['direction'].clear()
				for coord in dump[self.gradient.tag]:
					self.store['direction'].append(coord)

		def read_autoofset_settings(dump):
			with self.gui['handoffset_switch'].handler_block(self.signals['handoffset_switch']):
				self.gui['handoffset_switch'].set_active(not dump['autooffset'])
			self.gui['offset_scale'].set_sensitive(not dump['autooffset'])

		self.data_read_handler = {
			'colors': read_colors,
			'linearGradient': read_gradient_settings,
			'radialGradient': read_gradient_settings,
			'autooffset': read_autoofset_settings,
			'gradtype': read_gradient_type,
			'filter': read_filter_name,
		}

		# Write GUI setting to database
		def write_colors(dump):
			dump['colors'] = [list(row) for row in self.store['colorlist']]

		def write_gradient_type(dump):
			dump['gradtype'] = self.gradient.tag

		def write_autoofset_settings(dump):
			dump['autooffset'] = not self.gui['handoffset_switch'].get_active()

		def write_filter_name(dump):
			dump['filter'] = self.gui['filters_combo'].get_active_text()

		def write_gradient_settings(dump):
			dump[self.gradient.tag] = [list(row) for row in self.store['direction']]

		self.data_write_handler = {
			'gradtype': write_gradient_type,
			'autooffset': write_autoofset_settings,
			'filter': write_filter_name,
			'colors': write_colors,
			'linearGradient': write_gradient_settings,
			'radialGradient': write_gradient_settings,
		}

	# Support functions
	def read_gui_setting_from_base(self, keys=None):
		"""Read settings from file and set GUI according it"""
		keys = keys if keys is not None else self.get_current_base_keys()
		dump = self.database.get_dump(self.icongroups.current.name)

		for key in keys:
			self.data_read_handler[key](dump)

		self.update()

	def write_gui_settings_to_base(self, keys=None):
		"""Write settings to file"""
		keys = keys if keys is not None else self.get_current_base_keys()
		dump = self.database.get_dump(self.icongroups.current.name)

		for key in keys:
			self.data_write_handler[key](dump)

	def get_current_base_keys(self):
		"""Get current keys for databse access"""
		keys = ['filter', 'gradtype', 'autooffset', 'colors']
		keys.append(self.gradient.tag)
		return keys

	def set_offset_auto(self):
		"""Set fair offset for all colors in gradient"""
		rownum = len(self.store['colorlist'])
		if rownum > 1:
			step = 100 / (rownum - 1)
			for i, row in enumerate(self.store['colorlist']):
				row[self.ced['Offset']] = i * step
		elif rownum == 1:
			self.store['colorlist'][0][self.ced['Offset']] = 100

	def current_state(self):
		"""Get current icon settings"""
		return dict(
			gradient = self.gradient,
			gfilter = self.filters.current,
			data = self.database.get_dump(self.icongroups.current.name)
		)

	def filter_refresh(self, caller, forced):
		"""Filter update handler"""
		self.refresh(forced)

	def refresh(self, forced=False):
		"""Full update for GUI state"""
		if self.rtr or forced:
			self.write_gui_settings_to_base()
			self.update()

	def update(self):
		"""Refresh icon preview"""
		state = self.current_state()
		self.icongroups.current.preview = iconchanger.rebuild_text(self.icongroups.current.preview, **state)

		pixbuf = self.icongroups.current.get_preview_pixbuf(self.PREVIEW_ICON_SIZE)
		self.gui['preview_icon'].set_from_pixbuf(pixbuf)

	# GUI handlers
	def on_refresh_click(self, *args):
		self.write_gui_settings_to_base()
		self.update()

	def on_gradient_type_switched(self, combo):
		if self.init_confirmed:  # fix this: first switch
			self.write_gui_settings_to_base([self.gradient.tag])

		self.gradient.set_tag(combo.get_active_text())
		self.write_gui_settings_to_base(['gradtype'])
		self.read_gui_setting_from_base(['gradtype', self.gradient.tag])

	def on_direction_edited(self, widget, path, text):
		self.store['direction'][path][self.ded['Value']] = int(text)
		self.refresh()

	def on_custom_icon_toggled(self, widget, path):
		self.store['custom_icons'][path][self.ied['State']] = not self.store['custom_icons'][path][self.ied['State']]
		name = self.store['custom_icons'][path][self.ied['Name']].lower()
		self.icongroups.current.switch_state(name)
		self.refresh(forced=True)

	def on_offset_value_changed(self, scale):
		offset = scale.get_value()
		if self.color_selected is not None:
			self.store['colorlist'].set_value(self.color_selected, self.ced['Offset'], int(offset))
		self.refresh()

	def on_filter_group_combo_changed(self, combo):
		group = combo.get_active_text()
		self.filters.set_group(group)

		self.gui['filters_combo'].remove_all()
		for name in self.filters.names:
			self.gui['filters_combo'].append_text(name)

		self.gui['filters_combo'].set_active(0)

	def on_filter_combo_changed(self, combo):
		name = combo.get_active_text()
		if name is not None:
			self.filters.switch(name)
			self.gui['filter_settings_button'].set_sensitive(self.filters.current.is_custom)
			self.write_gui_settings_to_base(['filter'])
			self.update()

	def on_colorlist_structure_changed(self, *args):
		if self.database.get_key(self.icongroups.current.name, 'autooffset'):
			self.set_offset_auto()

		if len(self.store['colorlist']) > 0:
			last = len(self.store['colorlist']) - 1
			self.gui['colorlist_treeview'].set_cursor(last)
			self.gui['offset_scale'].set_value(self.store['colorlist'][last][self.ced['Offset']])

	def on_color_selection_changed(self, selection):
		model, sel = selection.get_selected()

		if sel is not None:
			self.color_selected = sel
			rgba = Gdk.RGBA()
			rgba.parse(model[sel][self.ced['RGBA']])
			rgba.alpha = model[sel][self.ced['Alpha']]
			self.gui['color_selector'].set_current_rgba(rgba)

			offset = model[sel][self.ced['Offset']]
			self.gui['offset_scale'].set_value(offset)

	def on_handoffset_toggled(self, switch, *args):
		is_active = switch.get_active()
		self.gui['offset_scale'].set_sensitive(is_active)
		self.write_gui_settings_to_base(['autooffset'])

		if self.database.get_key(self.icongroups.current.name, 'autooffset'):
			self.set_offset_auto()

		self.gui['offset_scale'].set_value(self.store['colorlist'][self.color_selected][self.ced['Offset']])

		self.refresh()

	def on_icongroup_combo_changed(self, combo):
		if self.init_confirmed:  # fix this: first switch
			self.write_gui_settings_to_base()
			files = self.icongroups.current.get_test()
			iconchanger.rebuild(*files, **self.current_state())

		self.icongroups.switch(combo.get_active_text())

		if self.icongroups.current.is_custom:
			self.store['custom_icons'].clear()
			for key, value in self.icongroups.current.state.items():
				self.store['custom_icons'].append([key.capitalize(), value])

		self.gui['custom_icons_treeview'].set_sensitive(self.icongroups.current.is_custom)

		self.read_gui_setting_from_base()

	def on_color_change(self, *args):
		rgba = self.gui['color_selector'].get_current_rgba()
		self.store['colorlist'].set_value(self.color_selected, self.ced['Color'], hex_from_rgba(rgba))
		self.store['colorlist'].set_value(self.color_selected, self.ced['Alpha'], rgba.alpha)
		self.store['colorlist'].set_value(self.color_selected, self.ced['RGBA'], rgba.to_string())
		self.refresh()

	def on_render_toggled(self, switch, *args):
		self.rtr = switch.get_active()
		self.config.set("Settings", "autorender", str(self.rtr))
		self.refresh()

	# Toolbar buttons handlers
	def on_add_color_button_click(self, *args):
		rgba = self.gui['color_selector'].get_current_rgba()
		hexcolor = hex_from_rgba(rgba)
		self.store['colorlist'].append([hexcolor, rgba.alpha, 100, rgba.to_string()])

	def on_remove_color_button_click(self, *args):
		if len(self.store['colorlist']) > 1:
			self.store['colorlist'].remove(self.color_selected)

	def on_copy_settings_button_click(self, *args):
		self.state_buffer = deepcopy(self.database.get_dump(self.icongroups.current.name))

	def on_paste_settings_button_click(self, *args):
		self.database.update(self.icongroups.current.name, self.state_buffer)
		self.read_gui_setting_from_base()

	def on_save_settings_button_click(self, *args):
		is_ok, file_ = self.filechooser.save()
		if is_ok:
			self.database.save_to_file(file_)

	def on_load_settings_button_click(self, *args):
		is_ok, file_ = self.filechooser.load()
		if is_ok:
			self.database.load_from_file(file_)
			self.read_gui_setting_from_base()

	def on_reset_settings_button_click(self, *args):
		self.database.reset(self.icongroups.current.name)
		self.read_gui_setting_from_base()

	def on_filter_settings_click(self, widget, data=None):
		self.filters.current.gui['window'].show_all()

	@multithread
	def on_apply_click(self, *args):
		files = self.icongroups.current.get_real()
		iconchanger.rebuild(*files, **self.current_state())

	def on_page_switch(self):
		self.gui['render_button'].emit("toggled")
