# -*- Mode: Python; indent-tabs-mode: t; python-indent: 4; tab-width: 4 -*-

import os
from acyls.lib.filters import FilterParameter, CustomFilterBase


class Filter(CustomFilterBase):

	def __init__(self):
		CustomFilterBase.__init__(self, os.path.dirname(__file__))
		self.name = "Stroke"

		visible_tag = self.dull['visual'].find(".//*[@id='visible1']")
		self.param['width'] = FilterParameter(visible_tag, 'style', 'width:(.+)', 'width:%.2f')
		self.param['scale'] = FilterParameter(visible_tag, 'transform', 'scale\((.+?)\) ', 'scale(%.2f) ')
		self.param['color'] = FilterParameter(visible_tag, 'style', '(rgb\(.+?\));', '%s;')
		self.param['alpha'] = FilterParameter(visible_tag, 'style', 'fill-opacity:(.+?);', 'fill-opacity:%.2f;')

		gui_elements = ["width", "scale", "colorbutton"]

		self.on_scale_changed = self.build_plain_handler('scale')
		self.on_width_changed = self.build_plain_handler('width')
		self.on_colorbutton_set = self.build_color_handler('color', 'alpha')

		self.gui_load(gui_elements)
		self.gui_setup()

		self.connect_scale_signal('scale', 'width')
		self.connect_colorbutton_signal('colorbutton')

	def gui_setup(self):
		self.gui_settler_plain('scale', 'width')
		self.gui_settler_color('colorbutton', 'color', 'alpha')
