# -*- Mode: Python; indent-tabs-mode: t; python-indent: 4; tab-width: 4 -*-

import os
from acyls.lib.filters import FilterParameter, CustomFilterBase


class Filter(CustomFilterBase):

	def __init__(self):
		CustomFilterBase.__init__(self, os.path.dirname(__file__))
		self.name = "Tartan"
		self.group = "Overlays"

		visible_tag = self.dull['visual'].find(".//*[@id='visible1']")
		turbulence1_tag = self.dull['filter'].find(".//*[@id='feTurbulence1']")
		turbulence2_tag = self.dull['filter'].find(".//*[@id='feTurbulence2']")

		self.param['scale'] = FilterParameter(visible_tag, 'transform', 'scale\((.+?)\) ', 'scale(%.2f) ')
		self.param['octaves_x'] = FilterParameter(turbulence2_tag, 'numOctaves', '(.+)', '%.1f')
		self.param['octaves_y'] = FilterParameter(turbulence1_tag, 'numOctaves', '(.+)', '%.1f')
		self.param['frequency_x'] = FilterParameter(turbulence2_tag, 'baseFrequency', '(.+?) ', '%.2f ')
		self.param['frequency_y'] = FilterParameter(turbulence1_tag, 'baseFrequency', ' (.+)', ' %.2f')

		gui_elements = ["scale", "octaves_x", "octaves_y", "frequency_x", "frequency_y"]

		self.on_scale_changed = self.build_plain_handler('scale')
		self.on_frequency_x_changed = self.build_plain_handler('frequency_x')
		self.on_frequency_y_changed = self.build_plain_handler('frequency_y')
		self.on_octaves_x_changed = self.build_plain_handler('octaves_x')
		self.on_octaves_y_changed = self.build_plain_handler('octaves_y')

		self.gui_load(gui_elements)
		self.gui_setup()

		self.connect_scale_signal('scale', 'frequency_x', 'frequency_y', 'octaves_x', 'octaves_y')

	def gui_setup(self):
		self.gui_settler_plain('scale', 'frequency_x', 'frequency_y', 'octaves_x', 'octaves_y')
