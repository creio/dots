# -*- Mode: Python; indent-tabs-mode: t; python-indent: 4; tab-width: 4 -*-
"""ACYLS functiont to work with file system"""

import os
import shutil
import configparser
import tempfile
import subprocess

from gi.repository import GdkPixbuf
from itertools import count


def get_svg_all(*dirlist):
	"""Find all SVG icon in directories"""
	filelist = []
	for path in dirlist:
		for root, _, files in os.walk(path):
			filelist.extend([os.path.join(root, name) for name in files if name.endswith('.svg')])
	return filelist


def get_svg_first(*dirlist):
	"""Find first SVG icon in directories"""
	for path in dirlist:
		for root, _, files in os.walk(path):
			for filename in files:
				if filename.endswith('.svg'):
					return os.path.join(root, filename)


def _is_dir(item):
	"""Check if given item has valid fs path"""
	if isinstance(item, list):
		return all((_is_dir(e) for e in item))
	else:
		return os.path.isdir(item)


def copy_with_su(source_dir, dest_dir):
	"""Copy file tree with root privileges if need"""
	if os.path.isdir(source_dir) and os.path.isdir(dest_dir):
		if os.access(dest_dir, os.W_OK):
			subprocess.call(["cp", "-rf", os.path.join(source_dir, "."), dest_dir])
		else:
			subprocess.call(["pkexec", "cp", "-rf", os.path.join(source_dir, "."), dest_dir])


def _read_icon_group_data(config, index, section):
	"""Read icon group data from config section"""
	# plain text arguments
	args = ("name", "pairdir", "emptydir", "testbase", "realbase")
	kargs = {k: config.get(section, k) for k in args if config.has_option(section, k)}

	# list type arguments
	args_l = ("testdirs", "realdirs")
	kargs_l = {k: config.get(section, k).split(";") for k in args_l if config.has_option(section, k)}

	# boolean type arguments
	args_b = ("pairsw", "custom")
	kargs_b = {k: config.getboolean(section, k) for k in args_b if config.has_option(section, k)}

	# collect it all together
	for d in (kargs_l, kargs_b):
		kargs.update(d)
		kargs['index'] = index

	# check directories
	for key in (k for k in kargs.keys() if k not in ("custom", "index", "name", "pairsw")):
		if not _is_dir(kargs[key]):
			raise FileNotFoundError()

	return kargs


class ConfigReader:
	"""Custom config parser"""
	def _double_config_action(method):
		def action(self, section, option):
			try:
				res = getattr(self.mainconfig, method)(section, option)
			except Exception as e:
				print(self.base_error_message % (section, option, e))
				res = getattr(self.backconfig, method)(section, option)
			return res
		return action

	def _direct_action(method):
		def action(self, *args):
			return getattr(self.mainconfig, method)(*args)
		return action

	def __init__(self, main_dir, backup_dir, filename):
		self.userfile = os.path.join(main_dir, filename)
		systemfile = os.path.join(backup_dir, filename)

		if not os.path.isfile(self.userfile) and os.path.isfile(systemfile):
			shutil.copy(systemfile, main_dir)

		self.mainconfig = configparser.ConfigParser()
		self.mainconfig.read(self.userfile)

		self.backconfig = configparser.ConfigParser()
		self.backconfig.read(systemfile)

		self.base_error_message = (
			"Fail to read user config section '%s' option '%s'\n%s\n"
			"Trying to get value from backup config\n"
		)

	get = _double_config_action("get")
	getint = _double_config_action("getint")
	getboolean = _double_config_action("getboolean")

	set = _direct_action("set")
	has_option = _direct_action("has_option")
	has_section = _direct_action("has_section")

	def getdir(self, section, option):
		"""Get directory from config"""
		try:
			res = self.mainconfig.get(section, option)
			if not os.path.isdir(res):
				raise FileNotFoundError("Directory '%s' was not found" % res)
		except Exception as e:
			print(self.base_error_message % (section, option, e))
			res = self.backconfig.get(section, option)
		return res

	def build_icon_groups(self, simple_group_class, custom_group_class, from_backup=False):
		"""Read all available icon group data from config"""
		pack = {}
		counter = count(1)
		config = self.backconfig if from_backup else self.mainconfig

		while True:
			index = next(counter)
			section = "IconGroup" + str(index)
			if not config.has_section(section):
				break
			try:
				group = _read_icon_group_data(config, index, section)
				is_custom = group.pop("custom")
				pack[group['name']] = custom_group_class(**group) if is_custom else simple_group_class(**group)
			except Exception as e:
				print("Fail to load icon group №%d\n%s" % (index, e))

		return pack

	def write(self):
		"""Write user config file"""
		with open(self.userfile, 'w') as configfile:
			self.mainconfig.write(configfile)


class Prospector:
	""""Find icons on diffrent deep level in directory tree"""
	def __init__(self, root):
		self.root = root
		self.structure = {0: dict(zip(('root', 'directories'), next(os.walk(root))))}

	def dig(self, name, level):
		"""Choose active directory on given level"""
		if level - 1 in self.structure and name in self.structure[level - 1]['directories']:
			dest = os.path.join(self.structure[level - 1]['root'], name)
			self.structure[level] = dict(zip(('root', 'directories'), next(os.walk(dest))))
			self.structure[level]['directories'].sort()
			self.structure = {key: self.structure[key] for key in self.structure if key <= level}

	def get_icons(self, level):
		"""Get icon list from given level"""
		if level in self.structure:
			return get_svg_all(self.structure[level]['root'])

	def send_icons(self, level, dest):
		"""Merge files form given level to destination place"""
		if level in self.structure:
			source_root_dir = self.structure[level]['root']
			for source_dir, _, files in os.walk(source_root_dir):
				destination_dir = source_dir.replace(source_root_dir, dest)
				for file_ in files:
					shutil.copy(os.path.join(source_dir, file_), destination_dir)


class AppThemeReader:
	"""Find applications themes in directory"""
	def __init__(self, root, icontype):
		self.root = root
		self.icontype = icontype
		self.cf = "config.ini"

		self.pack = {}
		self.active = None

		for dname in next(os.walk(root))[1]:
			configfile = os.path.join(root, dname, "config.ini")
			try:
				config = configparser.ConfigParser()
				config.read(configfile)

				name = config.get("Main", "name")
				path = config.get("Main", "path")
				comment = config.get("Main", "comment") if config.has_option("Main", "comment") else "No comments."
				if not os.path.isdir(path):
					raise Exception("Fail to read 'path' option")

				msize, mtype = self._read_custom_data(config)

				self.pack[name] = {"size": msize, "directory": dname, "path": path, "type": mtype, "comment": comment}
			except Exception as e:
				print("Fail to load applications icons from '%s'\n" % (dname,), e)

	def _read_custom_data(self, config, dsize=48, dtype="png"):
		"""Read complex icon settings from config"""
		isize = config.getint("Main", "size") if config.has_option("Main", "size") else dsize
		csize = {k: int(s) for k, s in config["Size"].items()} if config.has_section("Size") else []
		msize = {"main": isize, "custom": csize}

		itype = config.get("Main", "type") if config.has_option("Main", "type") else dtype
		itype = itype if itype in self.icontype else "png"
		ctype = {k: s for k, s in config["Type"].items() if s in self.icontype} if config.has_section("Type") else []
		mtype = {"main": itype, "custom": ctype}

		return msize, mtype

	def _read_subconfig_options(self, current_dir):
		"""Read date from optional config file"""
		try:
			config = configparser.ConfigParser()
			config.read(os.path.join(current_dir, self.cf))
			msize, mtype = self._read_custom_data(config, self.active["size"]["main"], self.active["type"]["main"])
		except Exception:
			msize = {"main": self.active["size"]["main"], "custom": {}}
			mtype = {"main": self.active["type"]["main"], "custom": {}}
		return msize, mtype

	def set_active_by_name(self, name):
		"""Set active icon theme"""
		self.active = self.pack[name]

	def get_icons(self):
		"""Get current theme icons"""
		filelist = []
		for root, _, files in os.walk(os.path.join(self.root, self.active['directory'])):
			for file_ in (os.path.join(root, name) for name in files):
				if file_.endswith('.svg') and not os.path.islink(file_):
					filelist.append(file_)
		return filelist

	def restore_theme(self, backup_dir):
		"""Copy application icon theme files from backup folder"""
		# read backup restore path
		try:
			config = configparser.ConfigParser()
			config.read(os.path.join(backup_dir, self.cf))
			dest_root_dir = config.get("Main", "path")
		except Exception as e:
			print("Fail to read backup settings\n%s" % e)
			return

		# use temporary directory to avoid write access problem
		with tempfile.TemporaryDirectory() as tdir:
			for source_dir, _, files in os.walk(backup_dir):
				subdir = os.path.relpath(source_dir, backup_dir)
				dest_dir = os.path.join(dest_root_dir, subdir)

				if not os.path.isdir(dest_dir):
					print("Can't restore icons because of missed folder:\n%s" % (dest_dir,))
					continue
				else:
					tdest_dir = os.path.join(tdir, subdir)
					if not os.path.isdir(tdest_dir):
						os.makedirs(tdest_dir)

				for icon in (f for f in files if f.split(".")[-1] in self.icontype):
					shutil.copy(os.path.join(source_dir, icon), os.path.join(tdest_dir, icon))

			# copy files to destination folder from temporary directory
			copy_with_su(tdir, dest_root_dir)

	def copy_theme(self, backup_dir=""):
		"""Copy application icon theme files"""
		source_root_dir = os.path.join(self.root, self.active["directory"])

		# make some preparations if backuping theme
		is_backuping = backup_dir != ""
		if is_backuping:
			os.makedirs(backup_dir)
			shutil.copyfile(os.path.join(source_root_dir, self.cf), os.path.join(backup_dir, self.cf))

		# use temporary directory to avoid write access problem
		with tempfile.TemporaryDirectory() as tdir:
			for source_dir, dirs, files in os.walk(source_root_dir):
				# read data from optional config file
				if source_dir != source_root_dir:
					msize, mtype = self._read_subconfig_options(source_dir)
				else:
					msize, mtype = self.active["size"], self.active["type"]

				# create directory structure
				subdir = os.path.relpath(source_dir, source_root_dir)
				for d in dirs:
					os.makedirs(os.path.join(os.path.join(tdir, subdir, d)))

				# save theme icons to temporary directory
				for icon in (f for f in files if f.endswith('.svg')):
					iname = icon[:-4]
					itype = mtype['custom'][iname] if iname in mtype['custom'] else mtype['main']

					if is_backuping:
						# copy original application files
						try:
							filename = icon[:-3] + itype
							source_file = os.path.join(self.active['path'], subdir, filename)
							dest_file = os.path.join(tdir, subdir, filename)
							shutil.copyfile(source_file, dest_file)
						except Exception as e:
							print("Fail to backup file:\n%s\n" % (source_file,), e)
					else:
						# copy acyls theme files
						source_file = os.path.join(source_dir, icon)
						if itype == "svg":
							dest_file = os.path.join(tdir, subdir, icon)
							shutil.copyfile(source_file, dest_file)
						else:
							isize = msize['custom'][iname] if iname in msize['custom'] else msize['main']
							dest_file = os.path.join(tdir, subdir, icon[:-3] + itype)
							pixbuf = GdkPixbuf.Pixbuf.new_from_file_at_size(source_file, isize, isize)
							pixbuf.savev(dest_file, itype, [], [])

			# copy files to destination folder from temporary directory
			dest_dir = backup_dir if is_backuping else self.active['path']
			copy_with_su(tdir, dest_dir)
