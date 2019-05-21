# -*- Mode: Python; indent-tabs-mode: t; python-indent: 4; tab-width: 4 -*-

import os
from acyls.lib.filters import FilterParameter, CustomFilterBase


class Filter(CustomFilterBase):

	def __init__(self):
		CustomFilterBase.__init__(self, os.path.dirname(__file__))
		self.name = "Organic"
		self.group = "Advanced"

		visible_tag = self.dull['visual'].find(".//*[@id='visible1']")
		turbulence_tag = self.dull['filter'].find(".//*[@id='feTurbulence1']")
		lighting_tag = self.dull['filter'].find(".//*[@id='feSpecularLighting1']")
		lighting2_tag = self.dull['filter'].find(".//*[@id='feSpecularLighting2']")

		self.param['scale'] = FilterParameter(visible_tag, 'transform', 'scale\((.+?)\) ', 'scale(%.2f) ')
		self.param['octaves'] = FilterParameter(turbulence_tag, 'numOctaves', '(.+)', '%.1f')
		self.param['frequency_x'] = FilterParameter(turbulence_tag, 'baseFrequency', '(.+?) ', '%.2f ')
		self.param['frequency_y'] = FilterParameter(turbulence_tag, 'baseFrequency', ' (.+)', ' %.2f')
		self.param['specular_cons'] = FilterParameter(lighting_tag, 'specularConstant', '(.+)', '%.1f')
		self.param['specular_exp'] = FilterParameter(lighting_tag, 'specularExponent', '(.+)', '%.1f')
		self.param['diff_cons'] = FilterParameter(lighting2_tag, 'diffuseConstant', '(.+)', '%.2f')
		self.param['surface'] = FilterParameter(lighting_tag, 'surfaceScale', '(.+)', '%.1f')
		self.param['surface2'] = FilterParameter(lighting2_tag, 'surfaceScale', '(.+)', '%.1f')

		gui_elements = [
			"scale", "octaves", "frequency_x", "frequency_y",
			"specular_cons", "specular_exp", "surface", "surface2", "diff_cons"
		]

		self.on_scale_changed = self.build_plain_handler('scale')
		self.on_frequency_x_changed = self.build_plain_handler('frequency_x')
		self.on_frequency_y_changed = self.build_plain_handler('frequency_y')
		self.on_octaves_changed = self.build_plain_handler('octaves')
		self.on_specular_cons_changed = self.build_plain_handler('specular_cons')
		self.on_specular_exp_changed = self.build_plain_handler('specular_exp')
		self.on_diff_cons_changed = self.build_plain_handler('diff_cons')
		self.on_surface_changed = self.build_plain_handler('surface')
		self.on_surface2_changed = self.build_plain_handler('surface2')

		self.gui_load(gui_elements)
		self.gui_setup()

		self.connect_scale_signal(
			'scale', 'frequency_x', 'frequency_y', 'octaves',
			'surface', 'specular_exp', 'specular_cons', 'surface2', 'diff_cons'
		)

	def gui_setup(self):
		self.gui_settler_plain(
			'scale', 'frequency_x', 'frequency_y', 'octaves',
			'surface', 'specular_exp', 'specular_cons', 'surface2', 'diff_cons'
		)
