# -*- Mode: Python; indent-tabs-mode: t; python-indent: 4; tab-width: 4 -*-

import os
from acyls.lib.filters import FilterParameter, CustomFilterBase


class Filter(CustomFilterBase):

	def __init__(self):
		CustomFilterBase.__init__(self, os.path.dirname(__file__))
		self.name = "Old Paper"
		self.group = "Advanced"

		visible_tag = self.dull['visual'].find(".//*[@id='visible1']")
		turbulence_tag = self.dull['filter'].find(".//*[@id='feTurbulence1']")
		displacement_tag = self.dull['filter'].find(".//*[@id='feDisplacementMap1']")
		light_tag = self.dull['filter'].find(".//*[@id='feDistantLight1']")
		composite_tag = self.dull['filter'].find(".//*[@id='feComposite2']")

		self.param['scale'] = FilterParameter(visible_tag, 'transform', 'scale\((.+?)\) ', 'scale(%.2f) ')
		self.param['octaves'] = FilterParameter(turbulence_tag, 'numOctaves', '(.+)', '%.1f')
		self.param['displacement'] = FilterParameter(displacement_tag, 'scale', '(.+)', '%.1f')
		self.param['elevation'] = FilterParameter(light_tag, 'elevation', '(.+)', '%.1f')
		self.param['frequency_x'] = FilterParameter(turbulence_tag, 'baseFrequency', '(.+?) ', '%.2f ')
		self.param['frequency_y'] = FilterParameter(turbulence_tag, 'baseFrequency', ' (.+)', ' %.2f')
		self.param['composite_k1'] = FilterParameter(composite_tag, 'k1', '(.+)', '%.1f')

		gui_elements = ["scale", "octaves", "frequency_x", "frequency_y", "displacement", "elevation", "composite_k1"]

		self.on_scale_changed = self.build_plain_handler('scale')
		self.on_frequency_x_changed = self.build_plain_handler('frequency_x')
		self.on_frequency_y_changed = self.build_plain_handler('frequency_y')
		self.on_octaves_changed = self.build_plain_handler('octaves')
		self.on_elevation_changed = self.build_plain_handler('elevation')
		self.on_displacement_changed = self.build_plain_handler('displacement')
		self.on_composite_k1_changed = self.build_plain_handler('composite_k1')

		self.gui_load(gui_elements)
		self.gui_setup()

		self.connect_scale_signal(
			'scale', 'frequency_x', 'frequency_y', 'composite_k1', 'octaves', 'displacement', 'elevation'
		)

	def gui_setup(self):
		self.gui_settler_plain(
			'scale', 'frequency_x', 'frequency_y', 'composite_k1', 'octaves', 'displacement', 'elevation'
		)
