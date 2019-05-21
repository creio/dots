# -*- Mode: Python; indent-tabs-mode: t; python-indent: 4; tab-width: 4 -*-
import os

_acyls_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
_dirs = dict(
	user = os.path.join(_acyls_dir, "data", "user"),
	default = os.path.join(_acyls_dir, "data", "default"),
	filters = os.path.join(_acyls_dir, "filters"),
	gui = os.path.join(_acyls_dir, "gui"),
	css = os.path.join(_acyls_dir, "css"),
)
