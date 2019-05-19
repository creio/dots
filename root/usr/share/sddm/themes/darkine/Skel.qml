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
import "components"
import "components/style" as Style

Style.Background {
    id: control

    property alias menu: taskbar.data
    property alias free: freespace.data
    property alias taskbar: taskbar           // Hook for Full-view button switch.

    property string position: config['menu.default.position']   // left, right.
    property string defaultSize: config['menu.default.size']    // mini, icon, tiny, half.
    property real taskbarMaxSize: 600

    property real miniSize // "max size" of each states.
    property real iconSize
    property real tinySize
    property real halfSize
    property real fullSize
    property string menuState: updateMenuState() // get the current menu state (mini, icon, tiny, half).

    readonly property bool isMini: root.menuState == "mini"
    readonly property bool isIcon: root.menuState == "icon"
    readonly property bool isTiny: root.menuState == "tiny"
    readonly property bool isHalf: root.menuState == "half"
    readonly property bool isFull: root.menuState == "full"
    readonly property bool isRight: position == "right"
    readonly property bool isMirror: isRight ? true : false

    readonly property real taskbarSize: taskbar.width
    readonly property real gripSize: config['menu/border.size']

    property real mousePosY

    Component.onCompleted: initSize()

    Text {
        anchors.fill: parent; z: 999; color: "red" 
        visible: false
        text: (
        " TaskbarSize : "+ taskbar.width +
        "\n ● state : "+menuState+
        "\n ● mini : "+miniSize+" - "+isMini+
        "\n ● icon : "+iconSize+" - "+isIcon+
        "\n ● tiny : "+tinySize+" - "+isTiny+
        "\n ● half : "+halfSize+" - "+isHalf+
        "\n ● full : "+fullSize+" - "+isFull+
        "\n - screensaver : "+screensaver.chrono+
        "\n - Mouse.Y : "+mousePosY)
    }

    Row {
        anchors.fill: parent ; spacing: 0
        LayoutMirroring.enabled: control.isMirror

        Item { 
            id: taskbar
            width: getDefaultSize()
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            Connections { 
                target: login
                onUserSelected: if (isIcon) taskbar.width = tinySize
            } 
            
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onClicked: screensaver.chrono = 0
                //onPositionChanged: screensaver.chrono = 0
                onDoubleClicked: if (!isFull) taskbar.width = miniSize
                //onEntered:
                //onExited:
                //onReleased:
                onPositionChanged: {
                    screensaver.chrono = 0;
                    mousePosY = mouse.y;
                }
            }

            Style.MenuBorder {
                id: border
                z: 100
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                LayoutMirroring.enabled: control.isMirror
                visible: !control.isFull

                menuState: control.menuState        // shared with skel.
                isPressed: borderArea.pressed       // Share borderArea event with MenuBorderStyle.
                isMouse: borderArea.containsMouse   // Share borderArea event with MenuBorderStyle.

                MouseArea {
                    id: borderArea
                    hoverEnabled: true
                    anchors.fill: parent
                    drag.target: parent; drag.axis: Drag.XAxis
                    onMouseXChanged: if (drag.active) control.updateLayout(mouseX)
                    onReleased: if (drag.active) control.mirrorLayout(mouseX)
                    onEntered: if (isMini) taskbar.width = iconSize
                }
            }
            Style.MenuBackground { anchors.fill: parent; LayoutMirroring.enabled: control.isMirror }
            // <MENU STUFF GO HERE YEAAAH>
        }

        Item {  
            id: freespace
            width: control.width - taskbar.width
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                propagateComposedEvents: true
                onClicked: screensaver.chrono = 0
                //onPositionChanged: screensaver.chrono = 0
                onDoubleClicked: if (isMini) taskbar.width = iconSize
                onPositionChanged: {
                    screensaver.chrono = 0;
                    mousePosY = mouse.y;
                }
            }
            // <FREE STUFF GO HERE YEAAAH>
        }
    }

    function updateMenuState() { 
        // Update menuState property.
        var w = taskbar.width;
        if (w == fullSize) return "full";
        if (w >= fullSize && w < iconSize) return "mini";
        if (w == iconSize) return "icon";
        if (w >= iconSize && w < halfSize) return "tiny";
        return "half";
    }

    function initSize() { 
        var facesize   = parseInt(config['userlist/icon.size']);
        var bordersize = parseInt(config['userlist/frame.spacing']);
        var textfield  = parseInt(config["textfield/width"]);
        var nbrVisibleUser = 3; //userModel.count

        // this is purely cosmetic and can be safe remove.
        var gripMargin = 36;

        // Update property values.
        fullSize = 0;
        miniSize = gripSize;
        iconSize = facesize + (bordersize*2);
        tinySize = iconSize + textfield + login.miniloginSize;
        halfSize = iconSize * nbrVisibleUser;

        // Adjust with gripSize & margins
        iconSize += gripSize;
        tinySize += gripMargin;

        if (halfSize <= tinySize) { halfSize = tinySize + 1; }
    }

    function getDefaultSize() {
        if (defaultSize == "mini") return miniSize;
        if (defaultSize == "icon") return iconSize;
        if (defaultSize == "tiny") return tinySize;
        if (defaultSize == "half") return halfSize;
        if (defaultSize == "halfmax") return taskbarMaxSize; // Alternative.
        if (defaultSize == "full") return 0;
        return iconSize;
    }



    function updateLayout(mousex) { 
        var pos = taskbar.width;
        isRight
            ? pos -= mousex
            : pos += mousex
        if (pos <= (miniSize + 20)) { pos = miniSize } else { if (pos < iconSize) pos = iconSize }
        if (pos > taskbarMaxSize) pos = taskbarMaxSize;
        taskbar.width = pos;
        if (pos > iconSize && pos < taskbarMaxSize && isRight) taskbar.x += mousex;
    }

    function mirrorLayout(mousex) { 
        var drop = width - taskbar.width;
        isRight
            ? drop += mousex
            : drop -= mousex
        if (drop < 300) {
            position = isRight ? "left" : "right";
            if (drop < iconSize) drop = iconSize;
            if (drop > taskbarMaxSize) drop = taskbarMaxSize;
            taskbar.width = drop;
        }
    }

}