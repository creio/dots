# -*- Mode: Python; indent-tabs-mode: t; python-indent: 4; tab-width: 4 -*-

import os
import dbm
import shelve
from copy import deepcopy

_default_section = {
	'gradtype': 'linearGradient',
	'filter': 'Disabled',
	'colors': [['#A0A0A0', 1.0, 100, 'rgb(160,160,160)']],
	'autooffset': True,
	'radialGradient': [['CenterX', 50], ['CenterY', 50], ['FocusX', 50], ['FocusY', 50], ['Radius', 50]],
	'linearGradient': [['StartX', 0], ['StartY', 0], ['EndX', 0], ['EndY', 100]]
}


class DataStore:
	"""Shelve database handler"""

	@staticmethod
	def strip_extension(db_filename):
		"""Strips the underlying database extension for ndbm databases"""
		ndbm_filename = os.path.splitext(db_filename)[0]
		return ndbm_filename \
			if dbm.whichdb(ndbm_filename) == 'dbm.ndbm' \
			else db_filename

	def __init__(self, dbfile, ddate=None, dsection='default'):
		self.db = shelve.open(dbfile, writeback=True)
		self.dsection = dsection
		self.ddate = ddate

		# Create base if not exist
		if len(self.db) == 0 or dsection not in self.db:
			if self.ddate is None:
				# with special 'Emblems' section
				self.ddate = {self.dsection: deepcopy(_default_section), 'Emblems': deepcopy(_default_section)}
				self.ddate['Emblems'].update({'colors': [['#404040', 1.0, 100, 'rgb(64,64,64)']]})
			self.db.update(self.ddate)

	def get_dump(self, section):
		"""Get data from given section of base"""
		if section not in self.db:
			self.db[section] = deepcopy(self.db[self.dsection])
		return self.db[section]

	def update(self, section, data):
		"""Update data in given section"""
		self.db[section].update(deepcopy(data))

	def reset(self, section):
		"""Reset given section to default"""
		self.db[section] = deepcopy(self.db[self.dsection])

	def get_key(self, section, key):
		"""Get from given section and key"""
		return self.db[section][key]

	def save_to_file(self, dbfile):
		"""Save current database to file"""
		try:
			with shelve.open(self.strip_extension(dbfile)) as newdb:
				for key in self.db:
					newdb[key] = self.db[key]
		except Exception as e:
			print("Fail to save settings to file:\n%s" % str(e))

	def load_from_file(self, dbfile):
		"""Load database from file"""
		try:
			with shelve.open(self.strip_extension(dbfile)) as newdb:
				for key in newdb:
					self.db[key] = newdb[key]
		except Exception as e:
			print("Fail to load settings from file:\n%s" % str(e))

	def clear(self, current_groups):
		"""Remove outdated database sections"""
		for section in filter(lambda key: key != self.dsection and key not in current_groups, self.db.keys()):
			del self.db[section]

	def close(self):
		"""Close database file"""
		self.db.close()
