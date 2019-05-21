# -*- Mode: Python; indent-tabs-mode: t; python-indent: 4; tab-width: 4 -*-
import os
import time
from gi.repository import Gtk, GObject
from gi.repository.GdkPixbuf import Pixbuf

import acyls
from acyls.lib.fssupport import AppThemeReader
from acyls.lib.guisupport import PixbufCreator, TreeViewHolder, FileChooser
from acyls.lib.multithread import multithread


class ApplicationsPage(GObject.GObject):
	"""Icon view GUI"""
	__gsignals__ = {'icons_loaded': (GObject.SIGNAL_RUN_FIRST, None, ())}

	def __init__(self, config):
		super().__init__()
		self.icontype = ("jpeg", "png", "tiff", "ico", "bmp", "svg")
		self.pixbufs = []

		# Create object for iconview
		self.themes_dir = config.getdir("Directories", "applications")
		self.backup_dir = config.getdir("Directories", "backup")

		self.appthemes = AppThemeReader(self.themes_dir, self.icontype)

		# File dialog
		self.filechooser = FileChooser(self.backup_dir)

		# Read icon size settins from config
		self.VIEW_ICON_SIZE = config.getint("PreviewSize", "group")

		# Load GUI
		self.builder = Gtk.Builder()
		self.builder.add_from_file(os.path.join(acyls.dirs['gui'], "applications.glade"))

		gui_elements = (
			'apps_grid', 'applications_combo', 'icons_view', 'path_label', 'message_label',
		)
		self.gui = {element: self.builder.get_object(element) for element in gui_elements}

		# Build store
		self.store = Gtk.ListStore(Pixbuf)
		self.gui['icons_view'].set_model(self.store)
		self.gui['icons_view'].set_pixbuf_column(0)
		self.iconview_lock = TreeViewHolder(self.gui['icons_view'])

		# Fill up GUI
		for name in self.appthemes.pack.keys():
			self.gui['applications_combo'].append_text(name)

		# connect signals
		self.gui['applications_combo'].connect("changed", self.on_applications_combo_changed)
		self.connect("icons_loaded", self.on_icons_loaded)

		# setup
		self.gui['applications_combo'].set_active(0)

		# Mainpage buttnons hanlers
		self.mhandlers = dict()
		self.mhandlers['apply_button'] = self.on_apply_click

		# Toolbar buttnons hanlers
		self.bhandlers = dict()
		self.bhandlers['make_backup_toolbutton'] = self.on_make_backup_button_click
		self.bhandlers['restore_backup_toolbutton'] = self.on_restore_backup_button_click

	# GUI handlers
	def on_icons_loaded(self, *args):
		self.gui['path_label'].set_text(self.appthemes.active["path"])
		self.gui['message_label'].set_text(self.appthemes.active["comment"])

		with self.iconview_lock:
			self.store.clear()
			for pix in self.pixbufs:
				self.store.append([pix])

	@multithread
	def on_applications_combo_changed(self, combo):
		text = combo.get_active_text()
		if text:
			self.appthemes.set_active_by_name(text)

			icons = self.appthemes.get_icons()
			self.pixbufs = [PixbufCreator.new_single_at_size(icon, self.VIEW_ICON_SIZE) for icon in icons]

			return "icons_loaded"

	def on_page_switch(self):
		self.gui['applications_combo'].emit("changed")

	def on_apply_click(self, *args):
		self.appthemes.copy_theme()

	def on_make_backup_button_click(self, *args):
		ct = time.strftime("%Y-%m-%d(%H:%M:%S)")
		backup_dir = os.path.join(self.backup_dir, self.appthemes.active["directory"] + "_" + ct)
		self.appthemes.copy_theme(backup_dir)

	def on_restore_backup_button_click(self, *args):
		is_ok, dir_ = self.filechooser.open_folder()
		if is_ok:
			self.appthemes.restore_theme(dir_)
