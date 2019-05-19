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

import QtQuick 2.5
import QtQuick.VirtualKeyboard 2.1

InputPanel {
    id: inputPanel
    property bool activated: false
    active: activated && Qt.inputMethod.visible
    visible: active
    width: parent.width

    Item {
        id: gripTop
        z: 1000
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 6
        MouseArea {
            anchors.fill: parent
            drag.target: inputPanel; drag.axis: Drag.XAndYAxis
        }
    }
    Item {
        id: gripLeft
        z: 1000
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        width: 36
        MouseArea {
            anchors.fill: parent
            drag.target: inputPanel; drag.axis: Drag.XAndYAxis
        }
    }
    Item {
        id: gripRight
        z: 1000
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: 36
        MouseArea {
            anchors.fill: parent
            drag.target: inputPanel; drag.axis: Drag.XAndYAxis
        }
    }
    Item {
        id: gripBottom
        z: 1000
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 26
        MouseArea {
            anchors.fill: parent
            drag.target: inputPanel; drag.axis: Drag.XAndYAxis
        }
    }
}

