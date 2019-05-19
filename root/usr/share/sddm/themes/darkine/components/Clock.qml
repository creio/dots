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
    readonly property bool softwareRendering: GraphicsInfo.api === GraphicsInfo.Software

    width: clock.implicitWidth
    height: clock.implicitHeight

    ColumnLayout {
        id: clock
        property date dateTime: new Date()
        spacing: 0

        Timer {
            id: timer
            interval: 1000; running: true; repeat: true;
            onTriggered: clock.dateTime = new Date()
        }
        
        Text {
            id: time
            Layout.alignment: Qt.AlignHCenter
            text : Qt.formatTime(clock.dateTime, conf("time.format"))
            color: conf("time.color")
            font.pointSize: conf("time.size")
            font.italic: conf("time.italic")
            font.bold: conf("time.bold")
            visible: conf("time.visible")
            Component.onCompleted: if (conf("time.font") != "") font.family = conf("time.font")
        }

        Text {
            id: date
            Layout.alignment: Qt.AlignHCenter
            text : Qt.formatDate(clock.dateTime, conf("date.format") == "" ? Qt.DefaultLocaleLongDate : conf("date.format"))
            color: conf("date.color")
            font.pointSize: conf("date.size")
            font.italic: conf("date.italic")
            font.bold: conf("date.bold")
            visible: conf("date.visible")
            font.capitalization: Font.Capitalize
            Component.onCompleted: if (conf("date.font") != "") font.family = conf("date.font")
        }
    } 

    // Shadow
    layer.enabled: !softwareRendering
    layer.effect: DropShadow {
        horizontalOffset: 0
        verticalOffset: 2
        radius: conf("shadow.radius")
        samples: 32
        spread: conf("shadow.spread")
        color: conf("shadow.color")
    }

    // Conf
    function conf(key, section) {
        var sec = (section === undefined ? "clock" : section);
        var val = config[sec + "/" + key];
        if (val === "true") {return true;}
        if (val === "false") {return false;}
        return val;
    }
}