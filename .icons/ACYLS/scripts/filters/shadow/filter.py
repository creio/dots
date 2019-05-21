# -*- Mode: Python; indent-tabs-mode: t; python-indent: 4; tab-width: 4 -*-

import os
from acyls.lib.filters import FilterParameter, CustomFilterBase


class Filter(CustomFilterBase):

	def __init__(self):
		CustomFilterBase.__init__(self, os.path.dirname(__file__))
		self.name = "Drop Shadow"
		self.group = "Shadows"

		visible_tag = self.dull['visual'].find(".//*[@id='visible1']")
		flood_tag = self.dull['filter'].find(".//*[@id='feFlood1']")
		blur_tag = self.dull['filter'].find(".//*[@id='feGaussianBlur1']")
		offset_tag = self.dull['filter'].find(".//*[@id='feOffset1']")

		self.param['alpha'] = FilterParameter(flood_tag, 'flood-opacity', '(.+)', '%.2f')
		self.param['dx'] = FilterParameter(offset_tag, 'dx', '(.+)', '%.2f')
		self.param['dy'] = FilterParameter(offset_tag, 'dy', '(.+)', '%.2f')
		self.param['blur'] = FilterParameter(blur_tag, 'stdDeviation', '(.+)', '%.2f')
		self.param['scale'] = FilterParameter(visible_tag, 'transform', 'scale\((.+?)\) ', 'scale(%.2f) ')
		self.param['color'] = FilterParameter(flood_tag, 'flood-color', '(.+)', '%s')

		gui_elements = ["alpha", "scale", "colorbutton", "blur", "dx", "dy"]

		self.on_scale_changed = self.build_plain_handler('scale')
		self.on_dx_changed = self.build_plain_handler('dx')
		self.on_dy_changed = self.build_plain_handler('dy')
		self.on_alpha_changed = self.build_plain_handler('alpha')
		self.on_blur_changed = self.build_plain_handler('blur')
		self.on_colorbutton_set = self.build_color_handler('color')

		self.gui_load(gui_elements)
		self.gui_setup()

		self.connect_scale_signal('scale', 'alpha', 'blur', 'dx', 'dy')
		self.connect_colorbutton_signal('colorbutton')

	def gui_setup(self):
		self.gui_settler_plain('scale', 'alpha', 'blur', 'dx', 'dy')
		self.gui_settler_color('colorbutton', 'color')
