# -*- Mode: Python; indent-tabs-mode: t; python-indent: 4; tab-width: 4 -*-

from lxml import etree

GRADIENT_PROFILES = dict(
	linearGradient = dict(
		titles = ("StartX", "StartY", "EndX", "EndY"),
		attributes = ('x1', 'y1', 'x2', 'y2'),
		index = 0
	),
	radialGradient = dict(
		titles = ("CenterX", "CenterY", "FocusX", "FocusY", "Radius"),
		attributes = ('cx', 'cy', 'fx', 'fy', 'r'),
		index = 1
	),
)


class Gradient:
	"""SVG gradient builder"""
	def __init__(self, tag='linearGradient'):
		self.set_tag(tag)

	def set_tag(self, tag):
		"""Set gradient type"""
		if tag in GRADIENT_PROFILES:
			self.tag = tag
			self.profile = GRADIENT_PROFILES[tag]

	def build(self, data):
		"""Build svg gradient tag"""
		# build attribute for gradient
		attr_list = data[self.tag]
		attr_persents = ["%d%%" % value for title, value in attr_list]
		attr_dict = dict(zip(self.profile['attributes'], attr_persents))
		attr_dict['id'] = "acyl-gradient"

		# create new gradient tag
		gradient = etree.Element(self.tag, attrib=attr_dict)

		# add colors to gradient tag
		for colordata in data['colors']:
			color, alpha, offset = colordata[:3]
			color_attr = {
				'offset': "%d%%" % offset,
				'style': "stop-color:%s;stop-opacity:%f" % (color, alpha)
			}
			etree.SubElement(gradient, 'stop', attrib=color_attr)

		return gradient
