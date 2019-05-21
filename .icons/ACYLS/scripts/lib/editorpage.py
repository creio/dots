# -*- Mode: Python; indent-tabs-mode: t; python-indent: 4; tab-width: 4 -*-
import os
from gi.repository import Gtk, Pango

import acyls
from acyls.lib.guisupport import PixbufCreator, FileChooser
from acyls.lib.filters import RawFilterEditor


class EditorPage:
	"""Filter editor GUI"""
	def __init__(self, filters, config):
		# Color page filters
		self.filters = filters

		# Filter edit helper
		self.filter_editor = RawFilterEditor(config.get("Editor", "preview"))

		# File dialog
		self.filechooser = FileChooser(acyls.dirs['filters'], "filter.xml")

		# Read icon size settins from config
		self.PREVIEW_ICON_SIZE = config.getint("PreviewSize", "single")

		# Load GUI
		self.builder = Gtk.Builder()
		self.builder.add_from_file(os.path.join(acyls.dirs['gui'], "editor.glade"))

		gui_elements = (
			'editor_grid', 'editor_textview', 'editor_preview_icon', 'filter_info_label',
		)
		self.gui = {element: self.builder.get_object(element) for element in gui_elements}
		self.gui['editor_textview'].modify_font(Pango.FontDescription("Monospace"))

		# Build buffer
		self.buffer = Gtk.TextBuffer(text="Enter filter source here")
		self.gui['editor_textview'].set_buffer(self.buffer)

		# Mainpage buttnons hanlers
		self.mhandlers = dict()
		self.mhandlers['refresh_button'] = self.on_refresh_click

		# Toolbar buttnons hanlers
		self.bhandlers = dict()
		self.bhandlers['edit_filter_toolbutton'] = self.on_edit_filter_button_click
		self.bhandlers['load_filter_toolbutton'] = self.on_load_filter_button_click
		self.bhandlers['revert_filter_toolbutton'] = self.on_revert_filter_button_click
		self.bhandlers['save_filter_toolbutton'] = self.on_save_filter_button_click
		self.bhandlers['save_as_filter_toolbutton'] = self.on_save_as_filter_button_click

		# Fill up GUI
		pixbuf = PixbufCreator.new_single_at_size(self.filter_editor.preview, self.PREVIEW_ICON_SIZE)
		self.gui['editor_preview_icon'].set_from_pixbuf(pixbuf)

	# Support functions
	def update_preview(self):
		"""Update filter preview"""
		try:
			pixbuf = PixbufCreator.new_single_at_size(self.filter_editor.current_preview, self.PREVIEW_ICON_SIZE)
			self.gui['editor_preview_icon'].set_from_pixbuf(pixbuf)
		except Exception:
			self.gui['editor_preview_icon'].set_from_icon_name('image-missing', Gtk.IconSize.DIALOG)

	def set_filter_from_file(self, file_):
		"""Load filter"""
		self.filter_editor.load_xml(file_)
		self.buffer.set_text(self.filter_editor.source)
		self.update_preview()
		self.gui['filter_info_label'].set_text(self.filter_editor.get_filter_info())

	# GUI handlers
	def on_edit_filter_button_click(self, *args):
		self.set_filter_from_file(self.filters.current.fstore)

	def on_load_filter_button_click(self, *args):
		is_ok, file_ = self.filechooser.load()
		if is_ok:
			self.set_filter_from_file(file_)

	def on_save_filter_button_click(self, *args):
		self.filter_editor.save_xml()

	def on_save_as_filter_button_click(self, *args):
		is_ok, file_ = self.filechooser.save()
		if is_ok:
			self.filter_editor.save_xml(file_)
			self.gui['filter_info_label'].set_text(self.filter_editor.get_filter_info())

	def on_revert_filter_button_click(self, *args):
		if self.filter_editor.xmlfile is not None:
			self.filter_editor.reset()
			self.buffer.set_text(self.filter_editor.source)
			self.update_preview()
		else:
			print("Error: filter was not saved")

	def on_refresh_click(self, *args):
		start, end = self.buffer.get_bounds()
		buffer_text = self.buffer.get_text(start, end, False)

		self.filter_editor.load_source(buffer_text)
		self.update_preview()
