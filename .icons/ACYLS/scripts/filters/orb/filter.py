# -*- Mode: Python; indent-tabs-mode: t; python-indent: 4; tab-width: 4 -*-

import os
from acyls.lib.filters import FilterParameter, CustomFilterBase


class Filter(CustomFilterBase):

	def __init__(self):
		CustomFilterBase.__init__(self, os.path.dirname(__file__))
		self.name = "Orb"
		self.group = "Advanced"

		visible2_tag = self.dull['visual'].find(".//*[@id='visible2']")
		visible1_tag = self.dull['visual'].find(".//*[@id='visible1']")
		mainorb_tag = self.dull['filter'].find(".//*[@id='c1']")
		stop1_tag = self.dull['filter'].find(".//*[@id='stop1']")
		stop2_tag = self.dull['filter'].find(".//*[@id='stop2']")
		grad_tag = self.dull['filter'].find(".//*[@id='linearGradient1']")

		self.param['scale'] = FilterParameter(visible2_tag, 'transform', 'scale\((.+?)\) ', 'scale(%.2f) ')
		self.param['reflex_scale'] = FilterParameter(
			grad_tag, 'gradientTransform', 'scale\((.+),1\) ', 'scale(%.1f,1) '
		)
		self.param['orb'] = FilterParameter(visible1_tag, 'transform', 'scale\((.+?)\) ', 'scale(%.2f) ')
		self.param['color'] = FilterParameter(mainorb_tag, 'style', 'fill:(rgb\(.+?\));', 'fill:%s;')
		self.param['stroke_color'] = FilterParameter(mainorb_tag, 'style', 'stroke:(rgb\(.+?\));', 'stroke:%s;')
		self.param['stop1_color'] = FilterParameter(stop1_tag, 'style', 'stop-color:(rgb\(.+?\));', 'stop-color:%s;')
		self.param['stop2_color'] = FilterParameter(stop2_tag, 'style', 'stop-color:(rgb\(.+?\));', 'stop-color:%s;')
		self.param['alpha'] = FilterParameter(mainorb_tag, 'style', 'fill-opacity:(.+?);', 'fill-opacity:%.2f;')
		self.param['stroke_alpha'] = FilterParameter(
			mainorb_tag, 'style', 'stroke-opacity:(.+?);', 'stroke-opacity:%.2f;'
		)
		self.param['stop_alpha'] = FilterParameter(stop1_tag, 'style', 'stop-opacity:(.+)', 'stop-opacity:%.2f')
		self.param['stroke_width'] = FilterParameter(mainorb_tag, 'style', 'stroke-width:(.+)', 'stroke-width:%.1f')

		gui_elements = [
			"scale", "orb", "colorbutton", "alpha", "stroke_alpha", "stop_alpha", "reflex_scale", "stroke_width"
		]

		self.on_scale_changed = self.build_plain_handler('scale')
		self.on_reflex_scale_changed = self.build_plain_handler('reflex_scale')
		self.on_alpha_changed = self.build_plain_handler('alpha')
		self.on_stroke_alpha_changed = self.build_plain_handler('stroke_alpha')
		self.on_stop_alpha_changed = self.build_plain_handler('stop_alpha')
		self.on_orb_changed = self.build_plain_handler('orb')
		self.on_stroke_width_changed = self.build_plain_handler('stroke_width')

		self.gui_load(gui_elements)
		self.gui_setup()

		self.connect_scale_signal('scale', 'orb', 'alpha', 'stroke_alpha', 'stop_alpha', 'reflex_scale', 'stroke_width')
		self.gui["colorbutton"].connect("color_set", self.advanced_colorbutton_setup)

	def gui_setup(self):
		self.gui_settler_plain('scale', 'orb', 'alpha', 'stroke_alpha', 'stop_alpha', 'reflex_scale', 'stroke_width')
		self.gui_settler_color('colorbutton', 'color')

	def advanced_colorbutton_setup(self, widget):
		rgba = widget.get_rgba()
		rgba_string = rgba.to_string()
		self.param['color'].set_value(rgba_string)
		self.param['stroke_color'].set_value(rgba_string)
		self.param['stop1_color'].set_value(rgba_string)
		self.param['stop2_color'].set_value(rgba_string)
		self.flag.emit("refresh", True)
