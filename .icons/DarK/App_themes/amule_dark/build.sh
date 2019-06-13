#!/bin/sh
set -e
basedir=`dirname "$(readlink -f "${0}")"`
cd ${basedir}
if (command -v zip >/dev/null 2>&1||command -v 7z >/dev/null 2>&1); then
	rm -rf amule_dark amule_dark.zip
	cp -R amule_dark_src amule_dark
	if (command -v zip >/dev/null 2>&1);then 
		zip -j amule_dark.zip amule_dark/*
	else
		7z a amule_dark.zip ${basedir}/amule_dark/*
	fi
	if [ -f amule_dark.zip ];then
		rm -rf amule_dark
	fi
fi
