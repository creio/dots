# -*- Mode: Python; indent-tabs-mode: t; python-indent: 4; tab-width: 4 -*-

import os
from acyls.lib.filters import FilterParameter, CustomFilterBase


class Filter(CustomFilterBase):

	def __init__(self):
		CustomFilterBase.__init__(self, os.path.dirname(__file__))
		self.name = "Dark Edges"
		self.group = "Shadows"

		visible_tag = self.dull['visual'].find(".//*[@id='visible1']")
		blur_tag = self.dull['filter'].find(".//*[@id='feGaussianBlur1']")
		self.param['deviation'] = FilterParameter(blur_tag, 'stdDeviation', '(.+)', '%.2f')
		self.param['scale'] = FilterParameter(visible_tag, 'transform', 'scale\((.+?)\) ', 'scale(%.2f) ')

		gui_elements = ["deviation", "scale"]

		self.on_scale_changed = self.build_plain_handler('scale')
		self.on_deviation_changed = self.build_plain_handler('deviation')

		self.gui_load(gui_elements)
		self.gui_setup()

		self.connect_scale_signal('scale', 'deviation')

	def gui_setup(self):
		self.gui_settler_plain('scale', 'deviation')
