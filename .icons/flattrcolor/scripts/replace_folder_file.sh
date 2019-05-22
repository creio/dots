#!/usr/bin/env bash
#	default color: 178984
oldglyph=#1d2e35
newglyph=#182a32

#	Front
#	default color: 36d7b7
oldfront=#3a5e6b
newfront=#315767

#	Back
#	default color: 1ba39c
oldback=#284049
newback=#223c47

sed -i "s/#524954/$oldglyph/g" $1
sed -i "s/#9b8aa0/$oldfront/g" $1
sed -i "s/#716475/$oldback/g" $1
sed -i "s/$oldglyph;/$newglyph;/g" $1
sed -i "s/$oldfront;/$newfront;/g" $1
sed -i "s/$oldback;/$newback;/g" $1
