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

// ============================================================
// BE AWARE, THIS IS A DELEGATE FILE of Skel (Main.qml)
// You can access on Skel propriety here !
// ============================================================

GridLayout {
    id: grid
    property bool newUser: false // Switch signal userlist < > usernameBox view.
    readonly property string usernameValue: newUser ? usernameBox.text : userlist.selectedUserLogin
    readonly property string passwordValue: passwordBox.text

    // For Skel.qml & javascript function.
    readonly property real miniloginSize: Math.round(miniloginButton.width + miniloginButton.anchors.leftMargin)

    implicitWidth: isFull ? root.width : taskbarSize
    LayoutMirroring.enabled: isMirror
    anchors.left: parent.left
    columns: (isHalf || isFull) ? 1 : 999
    columnSpacing: 0 // = Vertical (view) adjust.
    rowSpacing: 45

    // From userlist to Skel.qml : Propagation "onClicked" like.
    signal userSelected()  

    // ==============
    // Row/Column 1/2
    // ==============

    Item {
        Layout.preferredWidth: isFull ? root.width : isHalf ? taskbarSize : iconSize
        Layout.preferredHeight: grid.newUser ? newUserAvatar.height : userlist.height

        UserList {
            id: userlist
            //width: isFull ? root.width : implicitWidth
            anchors.horizontalCenter : parent.horizontalCenter
            orientationUserlist: (isHalf || isFull) ? "horizontal" : "vertical"
            showUsername: (isHalf || isFull) ? true : false
            clip: (isFull || !isHalf) ? false : true
            visible: grid.newUser ? false : true
                opacity: visible ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 500 } }
            onUserSelected: grid.userSelected()
        }

        User {
            id: newUserAvatar
            anchors.horizontalCenter : parent.horizontalCenter
            width: parent.width
            faceSize: config["userlist/icon.size"]
            borderSize: config["userlist/frame.spacing"]
            avatarPath: config["path/login.icon.default"]
            name: textConstants.prompt
            constrainText: true
            isCurrent: true
            showUsername: (isHalf || isFull) ? true : false
            visible: grid.newUser ? true : false
                opacity: visible ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 500 } }
            font.pointSize: 9
            font.bold: false
            font.italic: false
            onSelectMe: grid.userSelected()
        }
    }

    // ==============
    // Row/Column 2/2
    // ==============

    ColumnLayout {
        Layout.preferredWidth: isFull ? root.width : taskbarSize
        LayoutMirroring.enabled: isMirror

        UsernameLabel {
            Layout.leftMargin: 4
            Layout.rightMargin: 4
            text: userlist.selectedUserName
            visible: ((taskbarSize - iconSize) >= implicitWidth) && !grid.newUser && !(isHalf || isFull)
                opacity: visible ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 500 } }
        }

        NotificationMessage {
            id: notification
            LayoutMirroring.enabled: isMirror
            Layout.maximumWidth: isFull ? root.width : isHalf ? taskbarSize : (taskbarSize - iconSize)
            Layout.minimumWidth: (taskbarSize - iconSize)
            Layout.fillWidth: true
            Layout.preferredHeight: text == "" ? 1 : implicitHeight
            Layout.leftMargin: 4
            Layout.rightMargin: 4
            horizontalAlignment: (isHalf || isFull) ? Text.AlignHCenter : Text.AlignLeft
            visible: textboxVisible()
        }

        TextBox {
            id: usernameBox
            Layout.alignment: (isHalf || isFull) ? Qt.AlignCenter : Qt.AlignVCenter | Qt.AlignLeft
            Layout.preferredWidth: textboxWidth()
            Layout.topMargin: 5
            echoMode: TextInput.Normal
            placeholderText: textConstants.userName
            clearButtonShown: true
            revealPasswordButtonShown: false
            focus: visible ? true : false
            visible: textboxVisible() && grid.newUser
                opacity: visible ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 500 } }
            onAccepted: passwordBox.forceActiveFocus()
            // See : https://github.com/sddm/sddm/issues/202 (keyboard.layouts)
            Keys.onPressed: keyboardButton.displayText = keyboard.layouts[keyboard.currentLayout].longName;
        }

        TextBox {
            id: passwordBox
            Layout.alignment: (isHalf || isFull) ? Qt.AlignCenter : Qt.AlignVCenter | Qt.AlignLeft
            Layout.preferredWidth: textboxWidth()
            Layout.topMargin: 5
            echoMode: TextInput.Password
            placeholderText: textConstants.password
            clearButtonShown: true
            revealPasswordButtonShown: true
            focus: usernameBox.visible ? false : true
            visible: textboxVisible()
                opacity: visible ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 500 } }
            onAccepted: grid.login()
            Keys.onPressed: keyboardButton.displayText = keyboard.layouts[keyboard.currentLayout].longName;
        }

        LoginButton {
            id: loginButton
            Layout.alignment: Qt.AlignCenter
            Layout.preferredWidth: passwordBox.width
            Layout.topMargin: 5
            text: textConstants.login
            enabled: (grid.newUser && grid.usernameValue == "") ? false : true
            visible: (isHalf || isFull) ? true : false
                opacity: visible ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 500 } }
            onClicked: grid.login()
        }

        // *info : im not a ColumnLayout direct child.
        LoginButton {
            id: miniloginButton
            parent: passwordBox
            LayoutMirroring.enabled: isMirror
            anchors.left: parent.right
            anchors.leftMargin: 4
            text: isMirror ? "<" : ">"
            enabled: (grid.newUser && grid.usernameValue == "") ? false : true
            visible: !(isHalf || isFull) ? true : false
                opacity: visible ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 500 } }
            onClicked: grid.login()
        }
    }

    //Item { id: keepmeImAutoWidthAnchor; anchors.fill: parent } //finalydontkeepmeidoshit

    function textboxWidth() { 
        if (!isFull) {
            var size = (taskbarSize - iconSize) - miniloginSize;
            if (size < 0) return 0;
            if (size > parseInt(config["textfield/width"])) return parseInt(config["textfield/width"]);
            return size;
        }
        return parseInt(config["textfield/width"]);
    }

    function textboxVisible() { 
        if (!isFull) {
            var size = (taskbarSize - iconSize) - miniloginSize;  
            if (size < parseInt(config["textfield/width.min"])) return false;
        }
        return true;
    }


    // ==============
    // Misc
    // ==============

    Keys.onPressed: {
        if (event.key == Qt.Key_Left)  userlist.decrementCurrentIndex();
        if (event.key == Qt.Key_Right) userlist.incrementCurrentIndex();
        if (event.key == Qt.Key_Up)    userlist.incrementCurrentIndex();
        if (event.key == Qt.Key_Down)  userlist.decrementCurrentIndex();
    }

    Connections {
        target: sddm
        onLoginSucceeded: grid.opacity = 0
        onLoginFailed: { 
            notification.msg = textConstants.loginFailed;
            passwordBox.selectAll();
            passwordBox.forceActiveFocus();
        }
    }

    function login() { 
        if (grid.usernameValue !== "") {
            loginButton.visible ? loginButton.forceActiveFocus() : miniloginButton.forceActiveFocus();
            sddm.login(grid.usernameValue, grid.passwordValue, sessionButton.currentIndex);
        }
    }

}
