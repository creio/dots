# -*- Mode: Python; indent-tabs-mode: t; python-indent: 4; tab-width: 4 -*-

import os
from gi.repository import GdkPixbuf, Gio, GLib, Gtk, Gdk


dialogs_profile = dict(
	save = [
		"Save ACYL", None, Gtk.FileChooserAction.SAVE,
		(Gtk.STOCK_CANCEL, Gtk.ResponseType.CANCEL, Gtk.STOCK_SAVE, Gtk.ResponseType.OK)
	],
	load = [
		"Load ACYL", None, Gtk.FileChooserAction.OPEN,
		(Gtk.STOCK_CANCEL, Gtk.ResponseType.CANCEL, Gtk.STOCK_OPEN, Gtk.ResponseType.OK)
	],
	open_folder = [
		"Open folder", None, Gtk.FileChooserAction.SELECT_FOLDER,
		(Gtk.STOCK_CANCEL, Gtk.ResponseType.CANCEL, Gtk.STOCK_OPEN, Gtk.ResponseType.OK)
	]
)


def load_gtk_css(file_):
	"""Set custom CSS for Gtk theme"""
	style_provider = Gtk.CssProvider()
	style_provider.load_from_path(file_)

	Gtk.StyleContext.add_provider_for_screen(
		Gdk.Screen.get_default(),
		style_provider,
		Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
	)


def hex_from_rgba(rgba):
	"""Translate color from Gdk.RGBA to html hex format"""
	return "#%02X%02X%02X" % tuple([int(getattr(rgba, name) * 255) for name in ("red", "green", "blue")])


class TreeViewHolder():
	"""Disconnect treeview store"""
	def __init__(self, treeview):
		self.treeview = treeview

	def __enter__(self):
		self.store = self.treeview.get_model()
		self.treeview.set_model(None)

	def __exit__(self, type, value, traceback):
		self.treeview.set_model(self.store)


class FileChooser:
	"""File selection helper based on Gtk file dialog"""
	def _build_dialog_action(name):
		def action(self):
			response = self.dialogs[name].run()
			file_ = self.dialogs[name].get_filename()

			self.dialogs[name].hide()
			self.dialogs[name].set_current_folder(self.dialogs[name].get_current_folder())

			return response == Gtk.ResponseType.OK, file_
		return action

	def __init__(self, start_folder, default_name=""):
		self.dialogs = dict()
		for name, args in dialogs_profile.items():
			self.dialogs[name] = Gtk.FileChooserDialog(*args)
			self.dialogs[name].set_current_folder(start_folder)

		self.dialogs['save'].set_current_name(default_name)

	load = _build_dialog_action('load')
	save = _build_dialog_action('save')
	open_folder = _build_dialog_action('open_folder')


class PixbufCreator():
	"""Advanced pixbuf creator"""
	@classmethod
	def new_double_at_size(cls, *icons, size):
		"""Merge two icon in one pixbuf"""
		pixbuf = [cls.new_single_at_size(icon, size) for icon in icons]

		GdkPixbuf.Pixbuf.composite(
			pixbuf[1], pixbuf[0],
			0, 0,
			size, size,
			size / 2, size / 2,
			0.5, 0.5,
			GdkPixbuf.InterpType.BILINEAR,
			255)

		return pixbuf[0]

	@staticmethod
	def new_single_at_size(icon, size):
		"""Alias for creatinng pixbuf from file or string at size"""
		if os.path.isfile(icon):
			pixbuf = GdkPixbuf.Pixbuf.new_from_file_at_size(icon, size, size)
		else:
			stream = Gio.MemoryInputStream.new_from_bytes(GLib.Bytes.new(icon))
			pixbuf = GdkPixbuf.Pixbuf.new_from_stream_at_scale(stream, size, size, True)
		return pixbuf


class ActionHandler:
	"""Small helper to control an action"""
	def __init__(self, action, is_allowed=False):
		self.action = action
		self.is_allowed = is_allowed

	def set_state(self, state):
		"""Allow/block action"""
		self.is_allowed = state

	def run(self, *args, forced=False):
		"""Try to action"""
		if self.is_allowed or forced:
			self.action(*args)
