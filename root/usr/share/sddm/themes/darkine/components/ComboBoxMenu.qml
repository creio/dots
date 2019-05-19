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

ComboBox {
    id: control
    readonly property bool softwareRendering: GraphicsInfo.api === GraphicsInfo.Software
    hoverEnabled: true

    implicitWidth: Math.max(background ? background.implicitWidth : 0,
                            contentItem.implicitWidth + leftPadding + rightPadding) + indicator.implicitWidth + rightPadding

    implicitHeight: Math.max(background ? background.implicitHeight : 0)

    leftPadding: padding + (!control.mirrored || !indicator || !indicator.visible ? 0 : indicator.width + spacing)
    rightPadding: padding + (control.mirrored || !indicator || !indicator.visible ? 0 : indicator.width + spacing)


    // Combobox : Background.
    background: Rectangle {
        anchors.fill: parent
        radius: conf("radius")
        border.width: (control.pressed
                ? conf("border.size.press")
                : control.visualFocus
                    ? control.hovered ? conf("border.size.hover") : conf("border.size.focus")
                    : control.hovered ? conf("border.size.hover") : conf("border.size.normal")
                )
        border.color: (control.pressed
                ? conf("border.color.press")
                : control.visualFocus
                    ? control.hovered ? conf("border.color.hover") : conf("border.color.focus")
                    : control.hovered ? conf("border.color.hover") : conf("border.color.normal")
                )
        color: (control.pressed
                ? conf("background.color.press")
                : control.visualFocus
                    ? control.hovered ? conf("background.color.hover") : conf("background.color.focus")
                    : control.hovered ? conf("background.color.hover") : conf("background.color.normal")
                )

        // Shadow
        layer.enabled: !softwareRendering
        layer.effect: DropShadow {
            transparentBorder: true
            horizontalOffset: 0
            verticalOffset: 0
            samples: 32
            radius: conf("shadow.radius")
            spread: conf("shadow.spread")
            color: conf("shadow.color")
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            onWheel: {
                if (wheel.pixelDelta.y < 0 || wheel.angleDelta.y < 0) {
                    control.currentIndex = Math.min(control.currentIndex + 1, delegateModel.count -1);
                } else {
                    control.currentIndex = Math.max(control.currentIndex - 1, 0);
                }
                control.activated(control.currentIndex);
            }
        }
    }


    // Combobox : Text.
    contentItem: Text {
        id: textStyle
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        leftPadding: 12
        rightPadding: 0
        text: control.displayText
        color: (control.pressed
                ? conf("text.color.press")
                : control.visualFocus
                    ? control.hovered ? conf("text.color.hover") : conf("text.color.focus")
                    : control.hovered ? conf("text.color.hover") : conf("text.color.normal")
                )
        font.pointSize: conf("text.size")
        font.italic: conf("text.italic")
        font.bold: conf("text.bold")
        elide: Text.ElideRight
        Component.onCompleted: if (conf("text.font") != "") font.family = conf("text.font")
    }


    // Popup content : (text / background row).
    delegate: ItemDelegate {
        id: delegate
        width: control.popup.width
        height: 42
        text: control.textRole ? (Array.isArray(control.model) ? modelData[control.textRole] : model[control.textRole]) : modelData
        highlighted: control.highlightedIndex === index
        hoverEnabled: control.hoverEnabled
        
        contentItem: Item {
            anchors.fill: parent
            Image {
                id: flag
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: visible ? 8 : 0
                source: visible ? conf_path("combobox.folder.flags") + "/%1.png".arg(modelData.shortName) : "" 
                fillMode: Image.PreserveAspectFit
                height: visible ? conf_menu("flag.size") : 0
                visible: (Array.isArray(control.model) ? (modelData.shortName == "" || conf_menu("flag.visible") == false) ? false : true : false)
            }
            Text {
                anchors.left: flag.right
                anchors.verticalCenter: parent.verticalCenter
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignLeft
                leftPadding: 6
                rightPadding: 18
                text: delegate.text
                color: (delegate.pressed
                        ? conf_menu("text.color.press")
                        : delegate.focus
                            ? delegate.hovered ? conf_menu("text.color.hover") : conf_menu("text.color.focus")
                            : delegate.hovered ? conf_menu("text.color.hover") : conf_menu("text.color.normal")
                )
                font.pointSize: conf_menu("text.size")
                font.italic: conf_menu("text.italic")
                font.weight: control.currentIndex === index ? Font.Bold : Font.Normal
                elide: Text.ElideRight
                Component.onCompleted: if (conf_menu("text.font") != "") font.family = conf_menu("text.font")
            }
        }

        background: Rectangle {
            color: (delegate.pressed
                    ? conf("background.color.press")
                    : delegate.focus
                        ? delegate.hovered ? conf_menu("background.color.hover") : conf_menu("background.color.focus")
                        : delegate.hovered ? conf_menu("background.color.hover") : conf_menu("background.color.normal")
            )
            radius: conf_menu("radius")
        }
    }


    popup: Popup {
        id: popup
        y: control.height + 4
        width: control.width
        implicitHeight: Math.max(contentItem.implicitHeight + (padding * 2))
        padding: 3

        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: control.popup.visible ? control.delegateModel : null
            currentIndex: control.highlightedIndex
            ScrollIndicator.vertical: ScrollIndicator { }
        }
        
        background: Rectangle {
            anchors.fill: parent
            border.color: conf_popup("border.color.normal")
            border.width: 1
            color: conf_popup("background.color.normal")
            radius: conf_popup("radius")

            // Shadow
            layer.enabled: !softwareRendering
            layer.effect: DropShadow {
                transparentBorder: true
                horizontalOffset: 0
                verticalOffset: 0
                samples: 32
                radius: conf_popup("shadow.radius")
                spread: conf_popup("shadow.spread")
                color: conf_popup("shadow.color")
            }
        }
    }

    indicator: Image {
        x: control.mirrored ? control.padding : control.width - width - control.padding
        y: control.topPadding + (control.availableHeight - height) / 2
        source: conf_path("combobox.icon.arrow")
        opacity: enabled ? 1 : 0.3
        visible: conf("arrow.visible")
    }


    // Conf
    function conf(key, section) {
        var sec = (section === undefined ? "combobox" : section);
        var val = config[sec + "/" + key];
        if (val === "true") {return true;}
        if (val === "false") {return false;}
        return val;
    }
    
    function conf_popup(key) { 
        return conf(key, "combobox.popup");
    }

    function conf_menu(key) { 
        return conf(key, "combobox.menu");
    }

    function conf_path(key) { 
        return config['path/' + key];
    }
}
