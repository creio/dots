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
import QtQuick.Controls 2.0

Button {
    id: control
    activeFocusOnTab : false
    padding: 6
    spacing: 6
    hoverEnabled: true

    opacity: enabled ? 1 : 0.8

    contentItem: Text {
        text: control.text
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: (control.down 
                ? conf("text.color.press") : control.hovered 
                ? conf("text.color.hover") : conf("text.color.normal")
        )
        font.pointSize: conf("text.size")
        font.italic: conf("text.italic")
        font.bold: conf("text.bold")
        elide: Text.ElideRight
        Component.onCompleted: if (conf("text.font") != "") font.family = conf("text.font")
    }

    background: Rectangle {
        implicitHeight: Math.max(conf("height") - (border.width * 2))
        color: (control.down 
                ? conf("background.color.press") : control.hovered 
                ? conf("background.color.hover") : conf("background.color.normal")
        )
        border.color: (control.down 
                ? conf("border.color.press") : control.hovered 
                ? conf("border.color.hover") : conf("border.color.normal")
        )
        border.width: (control.down 
                ? conf("border.size.press") : control.hovered 
                ? conf("border.size.hover") : conf("border.size.normal")
        )
        radius: conf("radius")
    }


    // Conf
    function conf(key, section) {
        var sec = (section === undefined ? "button" : section);
        var val = config[sec + "/" + key];
        if (val === "true") {return true;}
        if (val === "false") {return false;}
        return val;
    }
}

