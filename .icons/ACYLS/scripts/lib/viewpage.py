# -*- Mode: Python; indent-tabs-mode: t; python-indent: 4; tab-width: 4 -*-
import os
from gi.repository import Gtk, GObject
from gi.repository.GdkPixbuf import Pixbuf

import acyls
from acyls.lib.fssupport import Prospector
from acyls.lib.guisupport import PixbufCreator, TreeViewHolder
from acyls.lib.multithread import multithread


class ViewerPage(GObject.GObject):
	"""Icon view GUI"""
	__gsignals__ = {'icons_loaded': (GObject.SIGNAL_RUN_FIRST, None, ())}

	def __init__(self, config):
		super().__init__()
		self.bhandlers = dict()
		self.mhandlers = dict()
		self.pixbufs = []

		# Create object for iconview
		self.iconview = Prospector(config.getdir("Directories", "real"))

		# Read icon size settins from config
		self.VIEW_ICON_SIZE = config.getint("PreviewSize", "group")

		# Load GUI
		self.builder = Gtk.Builder()
		self.builder.add_from_file(os.path.join(acyls.dirs['gui'], "viewer.glade"))

		gui_elements = (
			'iconview_grid', 'iconview_combo', 'icons_view',
		)
		self.gui = {element: self.builder.get_object(element) for element in gui_elements}

		# Build store
		self.store = Gtk.ListStore(Pixbuf)
		self.gui['icons_view'].set_model(self.store)
		self.gui['icons_view'].set_pixbuf_column(0)
		self.iconview_lock = TreeViewHolder(self.gui['icons_view'])

		# Fill up GUI
		for name in self.iconview.structure[0]['directories']:
			self.gui['iconview_combo'].append_text(name.capitalize())

		# connect signals
		self.gui['iconview_combo'].connect("changed", self.on_iconview_combo_changed)
		self.connect("icons_loaded", self.on_icons_loaded)

		# setup
		self.gui['iconview_combo'].set_active(0)

	# GUI handlers
	def on_icons_loaded(self, *args):
		with self.iconview_lock:
			self.store.clear()
			for pix in self.pixbufs:
				self.store.append([pix])

	@multithread
	def on_iconview_combo_changed(self, combo):
		DIG_LEVEL = 1
		text = combo.get_active_text()
		if text:
			self.iconview.dig(text.lower(), DIG_LEVEL)

			icons = self.iconview.get_icons(DIG_LEVEL)
			self.pixbufs = [PixbufCreator.new_single_at_size(icon, self.VIEW_ICON_SIZE) for icon in icons]

			return "icons_loaded"

	def on_page_switch(self):
		self.gui['iconview_combo'].emit("changed")
