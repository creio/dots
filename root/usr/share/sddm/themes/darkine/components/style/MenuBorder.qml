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
//import QtGraphicalEffects 1.12

Rectangle { 
    id: control
    property bool isPressed: false
    property bool isMouse: false
    property string menuState //not used atm

    implicitWidth: conf("border.size")
    //implicitWidth: menuState === "mini" ? conf("border.size") * 2 : conf("border.size")

    color: (control.isPressed
            ? conf("border.color.press")
            : control.isMouse ? conf("border.color.hover") : conf("border.color.normal")
    )
    opacity: (control.isPressed
            ? conf("border.opacity.press")
            : control.isMouse ? conf("border.opacity.hover") : conf("border.opacity.normal")
    )

/* 
    LinearGradient {
        id: fx
        property real speed: 500
        height: parent.height
        width: parent.width
        visible: control.isPressed
        start: Qt.point(0, 0)
        end: Qt.point(parent.height, parent.width)
        gradient: Gradient {
          GradientStop {
              SequentialAnimation on color {
                  loops: Animation.Infinite
                  ColorAnimation { from: Qt.rgba(1, 0, 0, 1); to: Qt.rgba(1, 1, 0, 1); duration: fx.speed }
                  ColorAnimation { from: Qt.rgba(1, 1, 0, 1); to: Qt.rgba(0, 1, 0, 1); duration: fx.speed }
                  ColorAnimation { from: Qt.rgba(0, 1, 0, 1); to: Qt.rgba(0, 1, 1, 1); duration: fx.speed }
                  ColorAnimation { from: Qt.rgba(0, 1, 1, 1); to: Qt.rgba(0, 0, 1, 1); duration: fx.speed }
                  ColorAnimation { from: Qt.rgba(0, 0, 1, 1); to: Qt.rgba(1, 0, 1, 1); duration: fx.speed }
                  ColorAnimation { from: Qt.rgba(1, 0, 1, 1); to: Qt.rgba(1, 0, 0, 1); duration: fx.speed }
              }
          }
        }
    }
 */

    // Conf
    function conf(key, section) {
        var sec = (section === undefined ? "menu" : section);
        var val = config[sec + "/" + key];
        if (val === "true") {return true;}
        if (val === "false") {return false;}
        return val;
    }
}