# -*- Mode: Python; indent-tabs-mode: t; python-indent: 4; tab-width: 4 -*-
import os
from gi.repository import Gtk

# User modules
import acyls
from acyls.lib.toolbar import MainToolBar
from acyls.lib.colorpage import ColorPage
from acyls.lib.altpage import AlternativesPage
from acyls.lib.viewpage import ViewerPage
from acyls.lib.editorpage import EditorPage
from acyls.lib.appspage import ApplicationsPage
from acyls.lib.guisupport import load_gtk_css, dialogs_profile
from acyls.lib.fssupport import ConfigReader
from acyls.lib.data import DataStore


class MainWindow:
	"""Main window constructor"""
	def __init__(self):
		self.last_button_handlers = dict()

		# Config file setup
		self.config = ConfigReader(acyls.dirs['user'], acyls.dirs['default'], "config.ini")

		# Set data file for saving icon render settings
		# Icon render setting will stored for every icon group separately
		self.database = DataStore(os.path.join(acyls.dirs['user'], "store.acyl"))

		# Load GUI
		self.builder = Gtk.Builder()
		self.builder.add_from_file(os.path.join(acyls.dirs['gui'], "main.glade"))

		gui_elements = (
			'window', 'notebook', 'exit_button', 'refresh_button', 'maingrid', 'apply_button',
		)
		self.gui = {element: self.builder.get_object(element) for element in gui_elements}
		self.buttons = ('refresh_button', 'apply_button')

		for args in dialogs_profile.values():
			args[1] = self.gui["window"]

		# Add panel
		self.toolbar = MainToolBar()
		self.gui['maingrid'].attach(self.toolbar.gui['toolbar'], 0, 0, 1, 1)

		# Add notebook pages
		self.pages = list()

		# colors
		self.colorpage = ColorPage(self.database, self.config)
		self.gui['notebook'].append_page(self.colorpage.gui['colorbox'], Gtk.Label('Colors'))
		self.pages.append(self.colorpage)

		# alternatives
		self.altpage = AlternativesPage(self.config)
		self.gui['notebook'].append_page(self.altpage.gui['alternatives_grid'], Gtk.Label('Alternatives'))
		self.pages.append(self.altpage)

		# viewer
		self.viewpage = ViewerPage(self.config)
		self.gui['notebook'].append_page(self.viewpage.gui['iconview_grid'], Gtk.Label('Icon View'))
		self.pages.append(self.viewpage)

		# filter editor
		self.editorpage = EditorPage(self.colorpage.filters, self.config)
		self.gui['notebook'].append_page(self.editorpage.gui['editor_grid'], Gtk.Label('Filter Editor'))
		self.pages.append(self.editorpage)

		# applications GUI icons
		self.appspage = ApplicationsPage(self.config)
		self.gui['notebook'].append_page(self.appspage.gui['apps_grid'], Gtk.Label('Applications'))
		self.pages.append(self.appspage)

		# Connect signals
		self.signals = dict()
		self.gui['window'].connect("delete-event", self.on_close_window)
		self.gui['exit_button'].connect("clicked", self.on_close_window)
		self.gui['notebook'].connect("switch_page", self.on_page_changed)

		self.colorpage.gui['render_button'].connect("toggled", self.on_render_toggled)

		for page in self.pages:
			if page.bhandlers:
				self.toolbar.connect_signals(page.bhandlers)

		# Load css
		try:
			load_gtk_css(os.path.join(acyls.dirs['css'], 'user_themefix.css'))
		except Exception:
			load_gtk_css(os.path.join(acyls.dirs['css'], 'themefix.css'))

		# Fill up GUI
		self.gui['notebook'].emit("switch_page", self.colorpage.gui['colorbox'], 0)
		self.gui['window'].show_all()

	# GUI handlers
	def on_page_changed(self, nb, page, index):
		self.toolbar.set_buttons_sensitive(self.pages[index].bhandlers)
		for button in self.buttons:
			if button in self.last_button_handlers:
				self.gui[button].disconnect_by_func(self.last_button_handlers[button])
			if button in self.pages[index].mhandlers:
				self.gui[button].connect("clicked", self.pages[index].mhandlers[button])

			self.gui[button].set_sensitive(button in self.pages[index].mhandlers)
		self.last_button_handlers = self.pages[index].mhandlers

		if hasattr(self.pages[index], 'on_page_switch'):
			self.pages[index].on_page_switch()

	def on_render_toggled(self, switch, *args):
		self.gui['refresh_button'].set_sensitive(not self.colorpage.rtr)

	def on_close_window(self, *args):
		self.database.clear(self.colorpage.icongroups.names)
		self.database.close()
		self.config.write()

		Gtk.main_quit(*args)
