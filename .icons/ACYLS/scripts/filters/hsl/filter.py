# -*- Mode: Python; indent-tabs-mode: t; python-indent: 4; tab-width: 4 -*-

import os
from acyls.lib.filters import FilterParameter, CustomFilterBase


class Filter(CustomFilterBase):

	def __init__(self):
		CustomFilterBase.__init__(self, os.path.dirname(__file__))
		self.name = "HSL"
		self.group = "Bumps"

		visible_tag = self.dull['visual'].find(".//*[@id='visible1']")
		blur_tag = self.dull['filter'].find(".//*[@id='feGaussianBlur1']")
		lighting1_tag = self.dull['filter'].find(".//*[@id='feSpecularLighting1']")
		light1_tag = self.dull['filter'].find(".//*[@id='feDistantLight1']")

		self.param['blur'] = FilterParameter(blur_tag, 'stdDeviation', '(.+)', '%.2f')
		self.param['specular'] = FilterParameter(lighting1_tag, 'specularConstant', '(.+)', '%.2f')
		self.param['scale'] = FilterParameter(visible_tag, 'transform', 'scale\((.+?)\) ', 'scale(%.2f) ')
		self.param['elevation'] = FilterParameter(light1_tag, 'elevation', '(.+)', '%.1f')
		self.param['surface'] = FilterParameter(lighting1_tag, 'surfaceScale', '(.+)', '%.1f')

		gui_elements = ["blur", "scale", "specular", "elevation", "surface"]

		self.on_scale_changed = self.build_plain_handler('scale')
		self.on_blur_changed = self.build_plain_handler('blur')
		self.on_specular_changed = self.build_plain_handler('specular')
		self.on_elevation_changed = self.build_plain_handler('elevation')
		self.on_surface_changed = self.build_plain_handler('surface')

		self.gui_load(gui_elements)
		self.gui_setup()

		self.connect_scale_signal('scale', 'blur', 'specular', 'elevation', 'surface')

	def gui_setup(self):
		self.gui_settler_plain('scale', 'blur', 'specular', 'elevation', 'surface')
