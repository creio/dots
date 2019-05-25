#!/usr/bin/env bash
#	default color: 178984
oldglyph=#4d5d70
newglyph=#4d5d70

#	Front
#	default color: 36d7b7
oldfront=#839ebe
newfront=#839ebe

#	Back
#	default color: 1ba39c
oldback=#5a6c82
newback=#5a6c82

sed -i "s/#524954/$oldglyph/g" $1
sed -i "s/#9b8aa0/$oldfront/g" $1
sed -i "s/#716475/$oldback/g" $1
sed -i "s/$oldglyph;/$newglyph;/g" $1
sed -i "s/$oldfront;/$newfront;/g" $1
sed -i "s/$oldback;/$newback;/g" $1
