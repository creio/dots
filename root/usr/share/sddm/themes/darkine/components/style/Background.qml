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

Item {
    id: background
    property string type: config.type
    property string color: config.color
    property string background: config.background

    readonly property bool isColor: type != "image"

    Rectangle {
        id: colorBG
        anchors.fill: parent
        visible: isColor
        color: background.color
    }

    Image {
        id: imageBG
        anchors.fill: parent
        visible: !isColor
        source: "../../" + background.background
        asynchronous: true
        cache: true
        smooth: true
        mipmap: true
        fillMode: Image.PreserveAspectCrop  
    }

    FastBlur {
        anchors.fill: imageBG
        source: imageBG
        visible: isColor ? false : (config["background.blur"] == "true")
        radius: config["background.blur.intensity"]
    }

}