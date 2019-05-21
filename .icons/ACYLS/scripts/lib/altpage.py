# -*- Mode: Python; indent-tabs-mode: t; python-indent: 4; tab-width: 4 -*-
import os
from gi.repository import Gtk
from gi.repository.GdkPixbuf import Pixbuf

import acyls
from acyls.lib.fssupport import Prospector
from acyls.lib.guisupport import PixbufCreator, TreeViewHolder


class AlternativesPage:
	"""Alternatives GUI"""
	def __init__(self, config):
		self.config = config
		self.bhandlers = dict()

		# Create objects for alternative and prewiew
		self.alternatives = Prospector(config.getdir("Directories", "alternatives"))

		# Read icon size settins from config
		self.VIEW_ICON_SIZE = config.getint("PreviewSize", "group")

		# Load GUI
		self.builder = Gtk.Builder()
		self.builder.add_from_file(os.path.join(acyls.dirs['gui'], "alternatives.glade"))

		gui_elements = (
			'alternatives_grid', 'alt_theme_combo', 'alt_group_combo', 'alt_icon_view',
		)
		self.gui = {element: self.builder.get_object(element) for element in gui_elements}

		# Mainpage buttnons hanlers
		self.mhandlers = dict()
		self.mhandlers['apply_button'] = self.on_apply_click

		# Build store
		self.store = Gtk.ListStore(Pixbuf)
		self.gui['alt_icon_view'].set_model(self.store)
		self.gui['alt_icon_view'].set_pixbuf_column(0)
		self.iconview_lock = TreeViewHolder(self.gui['alt_icon_view'])

		# Fill up GUI
		for name in self.alternatives.structure[0]['directories']:
			self.gui['alt_group_combo'].append_text(name.capitalize())

		# connect signals
		self.gui['alt_group_combo'].connect("changed", self.on_alt_group_combo_changed)
		self.gui['alt_theme_combo'].connect("changed", self.on_alt_theme_combo_changed)

		# setup
		self.gui['alt_group_combo'].set_active(0)

	# GUI handlers
	def on_apply_click(self, *args):
		DIG_LEVEL = 2
		self.alternatives.send_icons(DIG_LEVEL, self.config.getdir("Directories", "real"))

	def on_alt_group_combo_changed(self, combo):
		DIG_LEVEL = 1
		self.alternatives.dig(combo.get_active_text().lower(), DIG_LEVEL)

		self.gui['alt_theme_combo'].remove_all()
		for name in self.alternatives.structure[DIG_LEVEL]['directories']:
			self.gui['alt_theme_combo'].append_text(name.capitalize())

		self.gui['alt_theme_combo'].set_active(0)

	def on_alt_theme_combo_changed(self, combo):
		DIG_LEVEL = 2
		text = combo.get_active_text()
		if text:
			self.alternatives.dig(text.lower(), DIG_LEVEL)
			with self.iconview_lock:
				self.store.clear()
				for icon in self.alternatives.get_icons(DIG_LEVEL):
					pixbuf = PixbufCreator.new_single_at_size(icon, self.VIEW_ICON_SIZE)
					self.store.append([pixbuf])

	def on_page_switch(self):
		self.gui['alt_theme_combo'].emit("changed")
