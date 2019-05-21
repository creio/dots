#!/usr/bin/env python3
# -*- Mode: Python; indent-tabs-mode: t; python-indent: 4; tab-width: 4 -*-

import os
import sys
import imp

# Check requirements
import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk

if sys.version_info < (3, 4):
	sys.stdout.write("Requires Python 3.x\n")
	sys.exit(1)

# Load content of 'scrips' folder as 'acyls' module
# just don't want change current directory structure with 'scripts' and 'scalable' pair
moddata = imp.find_module('scripts', [os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")])
scripts = imp.load_module('scripts', *moddata)
sys.modules['acyls'] = scripts

# Load main app
from acyls.lib.mainwindow import MainWindow

# Set current working directory to be able use relative path in config
os.chdir(os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))

# Run application
if __name__ == "__main__":
	MainWindow()
	Gtk.main()
