# -*- Mode: Python; indent-tabs-mode: t; python-indent: 4; tab-width: 4 -*-

import os
import imp
import re
import acyls.lib.fssupport as fs
import acyls.lib.base as base

from lxml import etree
from copy import deepcopy
from gi.repository import Gtk, Gdk, GObject


class FilterParameter:
	"""Helper to find, change, save and restore certain value in xml tag attrubute.
	Used to work with svg filter parameters.
	"""
	def __init__(self, tag, attr, pattern, repl):
		self.tag = tag
		self.attr = attr
		self.pattern = pattern
		self.repl = repl

		self.remember()

	def match(self, gn=1):
		"""Get current value"""
		match = re.search(self.pattern, self.tag.attrib[self.attr])
		return match.group(gn)

	def set_value(self, value):
		"""Set value"""
		string = self.repl % value
		self.tag.attrib[self.attr] = re.sub(self.pattern, string, self.tag.attrib[self.attr])

	def remember(self):
		"""Remember current value"""
		self.last = self.match(gn=0)

	def restore(self):
		"""Restore last remembered value"""
		self.tag.attrib[self.attr] = re.sub(self.pattern, self.last, self.tag.attrib[self.attr])


class SimpleFilterBase:
	"""Base class for simple filter with fixes parameters."""
	def __init__(self, sourse_path):
		self.group = "General"
		self.is_custom = False
		self.path = sourse_path
		self.fstore = os.path.join(sourse_path, "filter.xml")
		self.load()

	def load(self):
		"""Load filter from xml file"""
		self.tree = etree.parse(self.fstore, base.parser)
		self.root = self.tree.getroot()
		filter_tag = self.root.find(".//*[@id='acyl-filter']")
		visual_tag = self.root.find(".//*[@id='acyl-visual']")

		self.dull = dict(filter=deepcopy(filter_tag), visual=deepcopy(visual_tag))

	def save(self):
		"""Save current model back to xml file"""
		self.root.replace(self.root.find(".//*[@id='acyl-filter']"), deepcopy(self.dull['filter']))
		self.root.replace(self.root.find(".//*[@id='acyl-visual']"), deepcopy(self.dull['visual']))
		self.tree.write(self.fstore, pretty_print=True)

	def get(self):
		"""Return a dict with filter tag and visual tag"""
		return self.dull


class Flag(GObject.GObject):
	"""Custom signal object"""
	__gsignals__ = {'refresh': (GObject.SIGNAL_RUN_FIRST, None, (bool,))}

	def __init__(self):
		GObject.GObject.__init__(self)


class CustomFilterBase(SimpleFilterBase):
	"""Base class for advanced filter with custimizible parametrs"""

	def __init__(self, sourse_path):
		SimpleFilterBase.__init__(self, sourse_path)
		self.is_custom = True
		self.param = dict()
		self.gui = dict()
		self.flag = Flag()

	def gui_load(self, gui_elements):
		"""Load filter setting GUI from glade file"""
		self.builder = Gtk.Builder()
		self.builder.add_from_file(os.path.join(self.path, "gui.glade"))

		gui_elements.extend(["window", "save_button", "cancel_button", "apply_button"])
		self.gui = {name: self.builder.get_object(name) for name in gui_elements}

		self.gui['window'].connect("delete_event", self.on_close_window)
		self.gui['save_button'].connect("clicked", self.on_save_click)
		self.gui['cancel_button'].connect("clicked", self.on_cancel_click)
		self.gui['apply_button'].connect("clicked", self.on_apply_click)

		# May cause exeption but should be catched by FilterCollector
		self.gui['window'].set_property("title", "ACYL Filter - %s" % self.name)

	def gui_setup(self):
		raise NotImplementedError("Method 'gui_setup' 'CustomFilterBase' should be defined in subclass")

	# GUI handlers
	def on_apply_click(self, *args):
		self.flag.emit("refresh", True)

	def on_save_click(self, *args):
		for parameter in self.param.values():
			parameter.remember()

		self.flag.emit("refresh", True)
		if 'window' in self.gui:
			self.gui['window'].hide()

		self.save()

	def on_cancel_click(self, *args):
		for parameter in self.param.values():
			parameter.restore()

		self.gui_setup()
		self.flag.emit("refresh", True)

	def on_close_window(self, *args):
		if 'window' in self.gui:
			self.gui['window'].hide()
		return True

	# GUI setup helpers
	def connect_scale_signal(self, *elementns):
		"""Scale signal connect helper"""
		for widget in elementns:
			self.gui[widget].connect("value_changed", self.__dict__["on_%s_changed" % widget])

	def connect_colorbutton_signal(self, *elementns):
		"""Color button signal connect helper"""
		for button in elementns:
			self.gui[button].connect("color_set", self.__dict__["on_%s_set" % button])

	def gui_settler_plain(self, *parameters, translate=float):
		"""GUI setup helper - simple parameters"""
		for parameter in parameters:
			self.gui[parameter].set_value(translate(self.param[parameter].match()))

	def gui_settler_color(self, button, color, alpha=None):
		"""GUI setup helper - color"""
		rgba = Gdk.RGBA()
		rgba.parse(self.param[color].match())
		if alpha is not None:
			rgba.alpha = float(self.param[alpha].match())
		self.gui[button].set_rgba(rgba)

	# Handler generators
	def build_plain_handler(self, *parameters, translate=None):
		"""Function factory.
		New handler changing simple filter parameter according GUI scale widget.
		"""
		def change_handler(widget):
			value = widget.get_value()
			if translate is not None:
				value = translate(value)
			for parameter in parameters:
				self.param[parameter].set_value(value)
			self.flag.emit("refresh", False)

		return change_handler

	def build_color_handler(self, color, alpha=None):
		"""Function factory.
		New handler changing color filter parameter according GUI colorbutton widget.
		"""
		def change_handler(widget):
			rgba = widget.get_rgba()
			if alpha is not None:
				self.param[alpha].set_value(rgba.alpha)
				rgba.alpha = 1  # dirty trick
			self.param[color].set_value(rgba.to_string())
			self.flag.emit("refresh", True)

		return change_handler


class FilterCollector(base.ItemPack):
	"""Object to load, store and switch between acyl-filters"""
	def __init__(self, path, filename='filter.py', dfilter='Disabled', dgroup='General'):
		self.default_filter = dfilter
		self.default_group = dgroup
		self.groups = dict()

		for root, _, files in os.walk(path):
			if filename in files:
				try:
					module = imp.load_source(filename.split('.')[0], os.path.join(root, filename))
					filter_ = module.Filter()
					self.add(filter_)
				except Exception as e:
					print("Fail to load filter from %s" % root)
					print(str(e))

		self.groupnames = list(self.groups.keys())
		self.groupnames.sort(key=lambda key: 1 if key == self.default_group else 2)
		self.set_group(self.groupnames[0])

	def add(self, filter_):
		"""Add new filter to collection"""
		group = filter_.group
		if group in self.groups:
			self.groups[group].update({filter_.name: filter_})
		else:
			self.groups[group] = {filter_.name: filter_}

	def set_group(self, group):
		"""Select filter group"""
		self.pack = self.groups[group]
		self.build_names(sortkey=lambda key: 1 if key == self.default_filter else 2)

	def get_group_index(self, name):
		"""Get group index by filter name"""
		for group, names in self.groups.items():
			if name in names:
				return self.groupnames.index(group)
		else:
			return 0

	def connect_signal(self, handler):
		"""Connect signal to all filters"""
		for group in self.groups.values():
			for filter_ in group.values():
				if filter_.is_custom:
					filter_.flag.connect("refresh", handler)


class RawFilterEditor:
	"""Filter editor"""
	def __init__(self, preview_dir):
		self.xmlfile = None

		preview_icon = fs.get_svg_first(preview_dir)
		with open(preview_icon, 'rb') as f:
			self.preview = f.read()

	def load_xml(self, file_):
		"""Load filter source from xml file"""
		self.xmlfile = file_
		self.load_source(file_)

	def update_preview(self):
		"""Update preview according current filter sourse"""
		iconroot = etree.fromstring(self.preview, base.parser)
		old_filter_tag, old_visual_tag = self.get_tags(iconroot)

		old_filter_tag.getparent().replace(old_filter_tag, deepcopy(self.filter_tag))
		old_visual_tag.getparent().replace(old_visual_tag, deepcopy(self.visual_tag))
		self.current_preview = etree.tostring(iconroot, pretty_print=True)

	def get_tags(self, root):
		filter_tag = root.find(".//*[@id='acyl-filter']")
		visual_tag = root.find(".//*[@id='acyl-visual']")
		return filter_tag, visual_tag

	def load_source(self, data):
		"""Update filter source"""
		try:
			if os.path.isfile(data):
				tree = etree.parse(data, base.parser)
				root = tree.getroot()
			else:
				root = etree.fromstring(data, base.parser)

			self.source = etree.tostring(root, pretty_print=True).decode("utf-8")
			self.filter_tag, self.visual_tag = self.get_tags(root)

			self.update_preview()
		except Exception as e:
			print("Fail to load filter source, wrong file or filter syntax")
			print(e)
			self.current_preview = ""

	def get_filter_info(self, modname="filter.py"):
		"""Try to get some information about filter by current xml file"""
		info = {'folder': "Unknown", 'group': "Unknown", 'name': "Unknown"}
		if self.xmlfile is not None:
			# Directory name may be useful
			dirname = os.path.dirname(self.xmlfile)
			info['folder'] = os.path.basename(dirname)

			# Check if filter module available in xml file directory
			try:
				module = imp.load_source(modname.split('.')[0], os.path.join(dirname, modname))
				filter_ = module.Filter()
				info['group'] = filter_.group
				info['name'] = filter_.name
			except Exception:
				print("Filter module was not found, no filter description available")

		info_str = "Folder: {folder}; Group: {group}; Name: {name}".format(**info)
		return info_str

	def reset(self):
		"""Reset filter to last saved state"""
		self.load_source(self.xmlfile)

	def save_xml(self, newfile=None):
		"""Save current filter state to file"""
		file_ = newfile if newfile is not None else self.xmlfile
		self.xmlfile = file_
		try:
			with open(file_, 'w') as f:
				f.write(self.source)
		except Exception as e:
			print("Can't save filter to file %s" % self.xmlfile)
			print(e)
