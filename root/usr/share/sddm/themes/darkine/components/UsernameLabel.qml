/*
 *   Copyright 2019 Romain V. <contact@rokin.in> - <https://github.com/Rokin05>
 *
 *   This program is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, see <https://www.gnu.org/licenses>.
 */

import QtQuick 2.8
import QtGraphicalEffects 1.0 

Text {
    readonly property bool softwareRendering: GraphicsInfo.api === GraphicsInfo.Software

    color: conf("text.color")
    font.pointSize: conf("text.size")
    font.italic: conf("text.italic")
    font.bold: conf("text.bold")
    font.capitalization: Font.Capitalize
    visible: text === "" ? false : true
    opacity: visible ? 1 : 0
    Component.onCompleted: if (conf("text.font") != "") font.family = conf("text.font")

    // Shadow
    layer.enabled: !softwareRendering
    layer.effect: DropShadow {
        horizontalOffset: 0
        verticalOffset: 0
        samples: 32
        radius: conf("shadow.radius")
        spread: conf("shadow.spread")
        color: conf("shadow.color")
    }


    // Conf
    function conf(key, section) {
        var sec = (section === undefined ? "label.username" : section);
        var val = config[sec + "/" + key];
        if (val === "true") {return true;}
        if (val === "false") {return false;}
        return val;
    }
}