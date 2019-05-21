# -*- Mode: Python; indent-tabs-mode: t; python-indent: 4; tab-width: 4 -*-

import os
from acyls.lib.filters import SimpleFilterBase


class Filter(SimpleFilterBase):

	def __init__(self, *args):
		SimpleFilterBase.__init__(self, os.path.dirname(__file__))
		self.name = "Disabled"
