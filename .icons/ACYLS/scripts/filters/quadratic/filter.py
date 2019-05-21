# -*- Mode: Python; indent-tabs-mode: t; python-indent: 4; tab-width: 4 -*-

import os
from acyls.lib.filters import FilterParameter, CustomFilterBase


class Filter(CustomFilterBase):

	def __init__(self):
		CustomFilterBase.__init__(self, os.path.dirname(__file__))
		self.name = "Quadratic"

		visible2_tag = self.dull['filter'].find(".//*[@id='supvis1']")
		support1_tag = self.dull['filter'].find(".//*[@id='support1']")
		support2_tag = self.dull['filter'].find(".//*[@id='support2']")
		support3_tag = self.dull['filter'].find(".//*[@id='support-rect']")

		self.param['scale_icon'] = FilterParameter(support1_tag, 'transform', 'scale\((.+?)\) ', 'scale(%.2f) ')
		self.param['scale'] = FilterParameter(support3_tag, 'transform', 'scale\((.+?)\) ', 'scale(%.2f) ')
		self.param['rx'] = FilterParameter(support3_tag, 'rx', '(.+)', '%.2f')
		self.param['ry'] = FilterParameter(support3_tag, 'ry', '(.+)', '%.2f')
		self.param['color'] = FilterParameter(support2_tag, 'style', '(rgb\(.+?\));', '%s;')
		self.param['alpha'] = FilterParameter(support2_tag, 'style', 'fill-opacity:(.+)', 'fill-opacity:%.2f')
		self.param['stroke_color'] = FilterParameter(visible2_tag, 'style', '(rgb\(.+?\));', '%s;')
		self.param['stroke_width'] = FilterParameter(visible2_tag, 'style', 'stroke-width:(.+)', 'stroke-width:%.2f')
		self.param['stroke_alpha'] = FilterParameter(
			visible2_tag, 'style', 'stroke-opacity:(.+?);', 'stroke-opacity:%.2f;'
		)

		gui_elements = ["scale", "scale_icon", "radius", "colorbutton", "stroke_colorbutton", "stroke_width"]

		self.on_scale_changed = self.build_plain_handler('scale')
		self.on_stroke_width_changed = self.build_plain_handler('stroke_width')
		self.on_scale_icon_changed = self.build_plain_handler('scale_icon')
		self.on_radius_changed = self.build_plain_handler('rx', 'ry')
		self.on_colorbutton_set = self.build_color_handler('color', 'alpha')
		self.on_stroke_colorbutton_set = self.build_color_handler('stroke_color', 'stroke_alpha')

		self.gui_load(gui_elements)
		self.gui_setup()

		self.connect_scale_signal('scale', 'radius', 'scale_icon', 'stroke_width')
		self.connect_colorbutton_signal('colorbutton', 'stroke_colorbutton')

	def gui_setup(self):
		self.gui['radius'].set_value(float(self.param['rx'].match()))
		self.gui_settler_plain('scale', 'scale_icon', 'stroke_width')
		self.gui_settler_color('colorbutton', 'color', 'alpha')
		self.gui_settler_color('stroke_colorbutton', 'stroke_color', 'stroke_alpha')
