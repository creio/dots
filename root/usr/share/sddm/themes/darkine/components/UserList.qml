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

ListView {
    id: view
    readonly property string selectedUserLogin: currentItem ? currentItem.userName : ""
    readonly property string selectedUserName: currentItem ? currentItem.name : ""

    property string orientationUsername     // left, right.
    property string orientationUserlist     // horizontal, vertical.
    property bool showUsername

    property real faceSize: conf("icon.size")
    property real borderSize: conf("frame.spacing")
    readonly property real userSize: (faceSize + (borderSize*2))

    orientation: view.orientationUserlist == "horizontal" ? ListView.Horizontal : ListView.Vertical
    highlightRangeMode: ListView.StrictlyEnforceRange
    activeFocusOnTab : false

    model: userModel
    currentIndex: userModel.lastIndex
    //highlightFollowsCurrentItem: count == 2 // Visual PATCH 2 users.
    
    signal userSelected()


    // Extend scrollzone.
    Rectangle {
        anchors.fill: parent; z: -999
        opacity: 0
        color: "red"
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
            onWheel: {
                wheel.accepted = true;
                if (wheel.angleDelta.y > 0) view.incrementCurrentIndex();
                if (wheel.angleDelta.y < 0) view.decrementCurrentIndex();
            }
        }
    }

    delegate: User {
        userName: model.name
        name: (model.realName === "") ? model.name : model.realName
        avatarPath: model.icon || ""
        iconSource: model.iconName || config['path/login.icon.default']

        faceSize: ListView.view.faceSize
        borderSize: ListView.view.borderSize

        orientationUserlist: ListView.view.orientationUserlist
        orientationUsername: ListView.view.orientationUsername

        // If we only one user.
        //constrainText: ListView.view.count > 1
        constrainText: true
        showUsername: ListView.view.showUsername

        isCurrent: ListView.isCurrentItem

        onMove_next: ListView.view.incrementCurrentIndex()
        onMove_prev: ListView.view.decrementCurrentIndex()

        onSelectMe: {
            ListView.view.currentIndex = index;
            ListView.view.userSelected(); 
        }

        Component.onCompleted: {
            if (orientationUserlist == "vertical" && showUsername == true) {
                if (orientationUsername == "right") anchors.left = parent.left;
                if (orientationUsername == "left") anchors.right = parent.right;
            }
        }
    }


    // Keys Naviguation.
    Keys.onEscapePressed: view.userSelected()
    Keys.onEnterPressed: view.userSelected()
    Keys.onReturnPressed: view.userSelected()
    

    Component.onCompleted: {
        implicitWidth = getImplicitWidth(orientationUserlist);
        implicitHeight = getImplicitHeight(orientationUserlist);
        updateHighlight();
    }

    onOrientationUserlistChanged: {
        implicitWidth = getImplicitWidth(orientationUserlist);
        implicitHeight = getImplicitHeight(orientationUserlist);
        updateHighlight();
    }

    // Hack recquire for recenter item on view change.
    // https://doc.qt.io/qt-5/qml-qtquick-listview.html
    onXChanged: {
        //currentIndex = userModel.lastIndex;
        if (count > 1) positionViewAtIndex(currentIndex, ListView.SnapPosition);
        //if (count > 2) positionViewAtIndex(currentIndex, ListView.SnapPosition); // Visual PATCH 2 users.
    }



    function getImplicitWidth(orientation) { 
        if (orientation == "horizontal") {
            //var nbrVisibleUser = 3; //count;
            var nbrVisibleUser = count == 1 ? 1 : 3; //count;
            return userSize * nbrVisibleUser;
        } else {
            return userSize;
        }
    }

    function getImplicitHeight(orientation) {
        if (orientation == "horizontal") {
            return userSize + (conf("text.size.focus") * 1.72);
        } else {
            //var nbrVisibleUser = 3; //count;
            var nbrVisibleUser = count == 1 ? 1 : 3; //count;
            return userSize * nbrVisibleUser;
        }
    }

    function updateHighlight() {

        // Visual PATCH 2 users.
        // if (count == 2) {
        //     preferredHighlightBegin = 0;
        //     preferredHighlightEnd = (orientationUserlist == "horizontal") ? width : height;
        //     return 0;
        // }

        var hSize = (faceSize / 2) + borderSize;
        if (orientationUserlist == "horizontal") {
            preferredHighlightBegin = (width / 2) - hSize;
        } else {
            preferredHighlightBegin = (height / 2) - hSize;
        }
        preferredHighlightEnd = preferredHighlightBegin + hSize;
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
