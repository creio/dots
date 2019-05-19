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
import "components"
import "components/artwork/fonts"

Skel {
    id: root
    width: 1920
    height: 1080

    // Init.
    Fonts { id: fonts }
    TextConstants { id: textConstants }


    menu: Item { id: menu; anchors.fill: parent }
    free: Item { id: free; anchors.fill: parent }

    
    
    // ===================
    // Objects
    // ===================

    Screensaver { id: screensaver; anchors.fill: parent }
    
    Login {
        id: login
        parent: isFull ? free : menu
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        visible: isMini ? false : true 
        //Rectangle {anchors.fill: parent; color: "red"; opacity: 0.1} //DEBUG
    }

    Clock { id: clock; parent: free }
        
    // Session and Keyboard buttons.
    RowLayout {
        id: combobox
        z: 2
        parent: free
        height: 30
        spacing: 4
        anchors.margins: 4
        LayoutMirroring.enabled: isMirror
        SessionButton {
            id: sessionButton
            Layout.fillWidth: false
            Layout.preferredWidth: 160
            Layout.fillHeight: false
            Layout.preferredHeight: 28
            Layout.rightMargin: 4
            visible: true
        }
        KeyboardButton {
            id: keyboardButton
            Layout.fillWidth: false
            Layout.preferredWidth: 140
            Layout.fillHeight: false
            Layout.preferredHeight: 28
            Layout.rightMargin: 4
            visible: true
        }
    }

    // SDDM actions buttons.
    RowLayout {
    id: actionButton
    parent: free
    anchors.margins: 0
    spacing: 32
        ActionButton {
            id: suspendButton
            Layout.fillWidth: false
            Layout.preferredWidth: visible ? config["action.button/icon.size"] : 0
            Layout.margins: 2
            visible: root.conf("enable.button.suspend")
            enabled: visible ? sddm.canSuspend : false
            //enabled: true
            iconSource: "components/"+config["path/action.icon.suspend"]
            text: textConstants.suspend
            onClicked: sddm.suspend()
        }
        ActionButton {
            id: rebootButton
            Layout.fillWidth: false
            Layout.preferredWidth: visible ? config["action.button/icon.size"] : 0
            Layout.margins: 2
            visible: root.conf("enable.button.reboot")
            enabled: visible ? sddm.canReboot : false
            //enabled: true
            text: textConstants.reboot
            iconSource: "components/"+config["path/action.icon.reboot"]
            onClicked: sddm.reboot()
        }
        ActionButton {
            id: shutdownButton
            Layout.fillWidth: false
            Layout.preferredWidth: visible ? config["action.button/icon.size"] : 0
            Layout.margins: 2
            visible: root.conf("enable.button.shutdown")
            enabled: visible ? sddm.canPowerOff : false
            //enabled: true
            text: textConstants.shutdown
            iconSource: "components/"+config["path/action.icon.shutdown"]
            onClicked: sddm.powerOff()
        }
        ActionButton {
            id: switchButton
            Layout.fillWidth: false
            Layout.preferredWidth: visible ? config["action.button/icon.size"] : 0
            Layout.margins: 2
            visible: root.conf("enable.button.otheruser")
            enabled: visible
            iconSource: "components/"+config["path/action.icon.switchuser"]
            onClicked: login.newUser = login.newUser ? false : true

            //i18nd : https://doc.qt.io/qt-5/qtquick-internationalization.html
            Component.onCompleted: {
                switch (Qt.locale().name.substring(0,2)) {
                    case "en": switchButton.text = "Different User"; break;
                    case "fr": switchButton.text = "Utilisateur différent"; break;
                    case "es": switchButton.text = "Usuario diferente"; break;
                    case "it": switchButton.text = "Utente diverso"; break;
                    case "de": switchButton.text = "Anderer Benutzer"; break;
                    default: switchButton.text = "Different User";
                }
            }
        }
    }

    // Button for switch in "full" view.
    ActionButton {
        id: fullsizeButton
        parent: free
        y: root.mousePosY
        anchors.left: parent.left
        LayoutMirroring.enabled: isMirror
        mirror: isMirror
        activeFocusOnTab : false
        visible: root.conf("enable.button.fullscreen.switch")
        opacity: isFull ? 0.1 : 0.1
        iconSize: 24
        iconSource: "components/"+config["path/action.icon.fullscreen"]
        MouseArea {
            hoverEnabled: false
            anchors.fill: parent
            drag.target: parent; drag.axis: Drag.XAxis
            onMouseXChanged: if (drag.active) root.updateLayout(mouseX)
            onReleased: if (drag.active) root.mirrorLayout(mouseX)
            onClicked: taskbar.width = (isMini || isFull) ? halfSize : 0
        }
    }

    // KDE Plasma stuff.
    Loader { 
        id: battery 
        parent: free
        anchors.margins: 4
        LayoutMirroring.enabled: isMirror
        source: "components/Battery.qml"
    }

    // Virtual Keyboard (opt).
    Loader {
        id: virtualKeyboard
        z: 200
        parent: free
        active: primaryScreen
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: actionButton.height + 22
        width: 800
        state: "hidden"
        source: "components/VirtualKeyboard.qml"
        property bool keyboardActive: item ? item.active : false
        onKeyboardActiveChanged: state = keyboardActive ? "visible" : "hidden"
        function show() {  
            state = "visible";
            Qt.inputMethod.show();
            virtualKeyboard.item.activated = true;
        }

        function hide() {  
            state = "hidden";
            Qt.inputMethod.hide();
            virtualKeyboard.item.activated = false;
        }
    }

    // Virtual Keyboard (opt).
    SwitchButton {
        id: virtualKeyboardButton
        z: 2
        parent: free
        anchors.margins: 4
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        LayoutMirroring.enabled: isMirror
        text: qsTr("Virtual Keyboard")
        position: 0
        visible: virtualKeyboard.status == Loader.Ready
        onPositionChanged: position == 1 ? virtualKeyboard.show() : virtualKeyboard.hide()
        //onClicked: position === 1 ? virtualKeyboard.show() : virtualKeyboard.hide()
    }


    // ==============
    // Misc
    // ==============
    
    // See : https://github.com/sddm/sddm/issues/202 (keyboard.layouts)
    Keys.onPressed: keyboardButton.displayText = keyboard.layouts[keyboard.currentLayout].longName;

    Component.onCompleted: {
        getPosition(clock, root.conf("position.clock"));
        getPosition(combobox, root.conf("position.combobox"));
        getPosition(actionButton, root.conf("position.button.action"));
        getPosition(battery, root.conf("position.battery"));
        getPosition(virtualKeyboardButton, root.conf("position.button.virtual.keyboard"));
       // getPosition(fullsizeButton, root.conf("position.button.fullsize"));
    }


    function getPosition(id, pos) {
        var p = id.parent;
        var o = id.anchors;
        if (pos == "top")          { id.anchors.top    = p.top;    id.anchors.horizontalCenter = p.horizontalCenter; return ""; }
        if (pos == "bottom")       { id.anchors.bottom = p.bottom; id.anchors.horizontalCenter = p.horizontalCenter; return ""; }
        if (pos == "left")         { id.anchors.left   = p.left;   id.anchors.verticalCenter   = p.verticalCenter; return ""; }
        if (pos == "right")        { id.anchors.right  = p.right;  id.anchors.verticalCenter   = p.verticalCenter; return ""; }
        if (pos == "top-left")     { id.anchors.top    = p.top;    id.anchors.left  = p.left;  return ""; }
        if (pos == "top-right")    { id.anchors.top    = p.top;    id.anchors.right = p.right; return ""; }
        if (pos == "bottom-left")  { id.anchors.bottom = p.bottom; id.anchors.left  = p.left;  return ""; }
        if (pos == "bottom-right") { id.anchors.bottom = p.bottom; id.anchors.right = p.right; return ""; }
    }

    function conf(key) { 
        var val = config[key];
        if (val === "true") {return true;}
        if (val === "false") {return false;}
        return val;
    }
}