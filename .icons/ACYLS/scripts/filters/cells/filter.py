# -*- Mode: Python; indent-tabs-mode: t; python-indent: 4; tab-width: 4 -*-

import os
from acyls.lib.filters import FilterParameter, CustomFilterBase


class Filter(CustomFilterBase):

	def __init__(self):
		CustomFilterBase.__init__(self, os.path.dirname(__file__))
		self.name = "Cells"
		self.group = "Overlays"

		visible_tag = self.dull['visual'].find(".//*[@id='visible1']")
		turbulence_tag = self.dull['filter'].find(".//*[@id='feTurbulence1']")
		blur_tag = self.dull['filter'].find(".//*[@id='feGaussianBlur1']")
		composite_tag = self.dull['filter'].find(".//*[@id='feComposite1']")

		self.param['scale'] = FilterParameter(visible_tag, 'transform', 'scale\((.+?)\) ', 'scale(%.2f) ')
		self.param['octaves'] = FilterParameter(turbulence_tag, 'numOctaves', '(.+)', '%.1f')
		self.param['blur'] = FilterParameter(blur_tag, 'stdDeviation', '(.+)', '%.1f')
		self.param['frequency_x'] = FilterParameter(turbulence_tag, 'baseFrequency', '(.+?) ', '%.2f ')
		self.param['frequency_y'] = FilterParameter(turbulence_tag, 'baseFrequency', ' (.+)', ' %.2f')
		self.param['composite_k1'] = FilterParameter(composite_tag, 'k1', '(.+)', '%.1f')
		self.param['composite_k2'] = FilterParameter(composite_tag, 'k2', '(.+)', '%.1f')
		self.param['composite_k3'] = FilterParameter(composite_tag, 'k3', '(.+)', '%.1f')

		gui_elements = [
			"scale", "octaves", "frequency_x", "frequency_y", "blur", "composite_k1", "composite_k2", "composite_k3"
		]

		self.on_scale_changed = self.build_plain_handler('scale')
		self.on_blur_changed = self.build_plain_handler('blur')
		self.on_frequency_x_changed = self.build_plain_handler('frequency_x')
		self.on_frequency_y_changed = self.build_plain_handler('frequency_y')
		self.on_composite_k1_changed = self.build_plain_handler('composite_k1')
		self.on_composite_k2_changed = self.build_plain_handler('composite_k2')
		self.on_composite_k3_changed = self.build_plain_handler('composite_k3')
		self.on_octaves_changed = self.build_plain_handler('octaves')

		self.gui_load(gui_elements)
		self.gui_setup()

		self.connect_scale_signal(
			'scale', 'frequency_x', 'frequency_y', 'blur', 'composite_k1', 'composite_k2', 'composite_k3', 'octaves'
		)

	def gui_setup(self):
		self.gui_settler_plain(
			'scale', 'frequency_x', 'frequency_y', 'blur', 'composite_k1', 'composite_k2', 'composite_k3', 'octaves'
		)
