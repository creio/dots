# -*- Mode: Python; indent-tabs-mode: t; python-indent: 4; tab-width: 4 -*-
import os
from gi.repository import Gtk

import acyls


class MainToolBar:
	"""Toolbar constructor"""
	def __init__(self):
		# Load GUI
		self.builder = Gtk.Builder()
		self.builder.add_from_file(os.path.join(acyls.dirs['gui'], "toolbar.glade"))

		gui_elements = (
			'toolbar', 'add_color_toolbutton', 'remove_color_toolbutton', 'copy_color_toolbutton',
			'paste_color_toolbutton', 'save_settings_toolbutton', 'load_settings_toolbutton',
			'reset_settings_toolbutton', 'load_filter_toolbutton', 'save_filter_toolbutton',
			'save_as_filter_toolbutton', 'revert_filter_toolbutton', 'edit_filter_toolbutton',
			'make_backup_toolbutton', 'restore_backup_toolbutton',
		)
		self.gui = {element: self.builder.get_object(element) for element in gui_elements}

		self.buttons = [e for e in gui_elements if e != 'toolbar']

	# Support functions
	def connect_signals(self, pack):
		"""Connect handlers to panel buttnons"""
		for button, handler in pack.items():
			self.gui[button].connect("clicked", handler)

	def set_buttons_sensitive(self, pack):
		for button in self.buttons:
			self.gui[button].set_sensitive(button in pack)
