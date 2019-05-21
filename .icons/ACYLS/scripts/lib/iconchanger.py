# -*- Mode: Python; indent-tabs-mode: t; python-indent: 4; tab-width: 4 -*-
"""SVG icon correction functions.
Some helpers to change ACYLS svg icons colected here.
"""

from lxml import etree
import acyls.lib.base as base


def rebuild(*files, gradient, gfilter, data):
	"""Replace gradient and filter in ACYLS svg icon files"""
	for icon in files:
		tree = etree.parse(icon, base.parser)
		root = tree.getroot()
		change_root(root, gradient, gfilter, data)
		tree.write(icon, pretty_print=True)


def change_root(root, gradient, gfilter, data):
	"""Replace gradient and filter tags in lxml element"""
	new_gradient_tag = gradient.build(data)
	new_filter_info = gfilter.get()
	XHTML = "{%s}" % root.nsmap[None]

	old_filter_tag = root.find(".//%s*[@id='acyl-filter']" % XHTML)
	old_visual_tag = root.find(".//%s*[@id='acyl-visual']" % XHTML)
	old_filter_tag.getparent().replace(old_filter_tag, new_filter_info['filter'])
	old_visual_tag.getparent().replace(old_visual_tag, new_filter_info['visual'])

	old_gradient_tag = root.find(".//%s*[@id='acyl-gradient']" % XHTML)
	old_gradient_tag.getparent().replace(old_gradient_tag, new_gradient_tag)


def rebuild_text(text, gradient, gfilter, data):
	"""Replace gradient and filter tags in given text"""
	root = etree.fromstring(text, base.parser)
	change_root(root, gradient, gfilter, data)
	return etree.tostring(root)
