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
import QtGraphicalEffects 1.0 

Item {
    id: control
    readonly property bool softwareRendering: GraphicsInfo.api === GraphicsInfo.Software
    property alias text: label.text
    property alias iconSource: icon.source
    property alias mirror: icon.mirror
    property int iconSize: conf("icon.size")
    readonly property bool noLabel: text == ""

    signal clicked
    activeFocusOnTab: true

    implicitWidth: noLabel ? Math.max(iconSize) : Math.max(iconSize + label.contentWidth + label.anchors.leftMargin + label.anchors.rightMargin)
    implicitHeight: noLabel ? Math.max(iconSize) : Math.max(iconSize + label.implicitHeight + label.anchors.topMargin + label.anchors.bottomMargin)

    Image {
        id: icon
        width: iconSize ; height: iconSize
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        opacity: (control.enabled ? mouseArea.containsMouse || control.focus 
                ? conf("opacity.hover") : conf("opacity.normal") : conf("opacity.disabled")
        )
        smooth: true
        mipmap: true
        antialiasing: true

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: control.clicked()
            onEntered: label.visible = conf("text.visible")
            onExited: label.visible = conf("text.visible") ? !conf("text.autohide") : false
        }
        // Shadow
        layer.enabled: !control.softwareRendering
        layer.effect: DropShadow {
            horizontalOffset: 0
            verticalOffset: 1
            samples: 32
            radius: conf("shadow.radius")
            spread: conf("shadow.spread")
            color: conf("shadow.color")
        }
    }

    Label {
        id: label
        anchors.topMargin: 4
        anchors.top: icon.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignTop
        visible: conf("text.visible") ? !conf("text.autohide") : false
        color: (mouseArea.pressed
                ? conf("text.color.press")
                : control.focus
                    ? mouseArea.containsMouse ? conf("text.color.hover") : conf("text.color.focus")
                    : mouseArea.containsMouse ? conf("text.color.hover") : conf("text.color.normal")
        )
        font.pointSize: conf("text.size")
        font.italic: conf("text.italic")
        font.bold: conf("text.bold")
        wrapMode: Text.WordWrap
        opacity: (control.enabled ? mouseArea.containsMouse || control.focus 
                ? conf("opacity.hover") : conf("opacity.normal") : conf("opacity.disabled")
        )
        Component.onCompleted: if (conf("text.font") != "") font.family = conf("text.font")
    }

    Keys.onEnterPressed: clicked()
    Keys.onReturnPressed: clicked()
    Keys.onSpacePressed: clicked()

    Accessible.onPressAction: clicked()
    Accessible.role: Accessible.Button
    Accessible.name: label.text

    // Conf
    function conf(key, section) {
        var sec = (section === undefined ? "action.button" : section);
        var val = config[sec + "/" + key];
        if (val === "true") {return true;}
        if (val === "false") {return false;}
        return val;
    }

}
