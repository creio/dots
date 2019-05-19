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
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0 

Item {
    id: user
    // QML shadows aren't supported with software rendering.
    readonly property bool softwareRendering: GraphicsInfo.api === GraphicsInfo.Software
    property bool isCurrent
    property string name
    property string userName
    property string avatarPath
    property string iconSource
    property real faceSize
    property real borderSize
    property string orientationUserlist     // vertical, horizontal.
    property string orientationUsername     // left, right.
    property bool constrainText
    property bool showUsername

    // Hook for id: newUserAvatar (login.qml).
    property alias font: username.font
    property bool isDefaultUser: avatarPath == config["path/login.icon.default"]

    implicitHeight: user.getImplicitHeight()
    implicitWidth: user.getImplicitWidth()

    width: implicitWidth
    height: implicitHeight

    opacity: isCurrent ? 1 : 0.6

    //Signaux ENVOYES
    signal selectMe()
    signal move_next()
    signal move_prev()

    //Behavior on opacity { OpacityAnimator { duration: 100 } }
    //Behavior on faceSize { NumberAnimation { duration: 100 } }


    GridLayout {
        id: grid
        anchors.fill: parent 
        columns: user.orientationUserlist ==  "vertical" ? 999 : 1
        layoutDirection: user.orientationUsername == "left" ? Qt.RightToLeft : Qt.LeftToRight
        columnSpacing: 5 // = vertical spacing.
        rowSpacing: 0

        Item {
            Layout.alignment: Qt.AlignCenter
            Layout.fillWidth: false
            Layout.fillHeight: false
            Layout.preferredWidth: faceSize
            Layout.preferredHeight: faceSize
            Image {
                id: avatar
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                source: user.avatarPath
                sourceSize: Qt.size(faceSize, faceSize)
                visible: true
                fillMode: Image.PreserveAspectCrop
                Component.onCompleted: avatar.status != Image.Error && avatar.status != Image.Null || (avatar.source = user.iconSource)
                layer.enabled: isDefaultUser ? conf("icon.round.defaultface") : conf("icon.round")
                layer.effect: OpacityMask {
                    source: avatar
                    maskSource: roundMask
                }
            }
            Rectangle {
                id: roundMask
                width: faceSize
                height: faceSize
                radius: faceSize / 2
                visible: false
            }
        }

        Text {
            id: username
            Layout.alignment: Qt.AlignCenter
            text: user.isCurrent ? user.name : ""
            color: user.isCurrent ? conf("text.color.focus") : conf("text.color.normal")
            font.pointSize: user.isCurrent ? conf("text.size.focus") : conf("text.size.normal")
            font.bold: user.isCurrent ? conf("text.bold.focus") : conf("text.bold.normal")
            font.italic: conf("text.italic")
            font.capitalization: Font.Capitalize
            visible: showUsername && constrainText
            Component.onCompleted: if (conf("text.font") != "") font.family = conf("text.font")
        }
    }

    // Shadow
    layer.enabled: !softwareRendering
    layer.effect: DropShadow {
        horizontalOffset: 0
        verticalOffset: 2
        samples: 32
        radius: conf("shadow.radius")
        spread: conf("shadow.spread")
        color: conf("shadow.color")
    }

    MouseArea {
        anchors.fill: parent
        onClicked: user.selectMe()
        onWheel: {
            wheel.accepted = true;
            if (wheel.angleDelta.y > 0) user.move_next();
            if (wheel.angleDelta.y < 0) user.move_prev();
        }
    }


    Accessible.name: name
    Accessible.role: Accessible.Button
    function accessiblePressAction() { user.selectMe() }


    function getImplicitWidth() { 
        var count = faceSize + (borderSize*2);
        if (username.visible && orientationUserlist == "vertical") {
            count += (grid.columnSpacing + username.implicitWidth);
        }
        return Math.round(count);
    }

    function getImplicitHeight() { 
        var count = faceSize + (borderSize*2);
        if (username.visible && orientationUserlist == "horizontal") count += (grid.rowSpacing + username.implicitHeight);
        return Math.round(count);
    }

    // Conf
    function conf(key, section) {
        var sec = (section === undefined ? "userlist" : section);
        var val = config[sec + "/" + key];
        if (val === "true") {return true;}
        if (val === "false") {return false;}
        return val;
    }
}