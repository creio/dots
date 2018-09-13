import QtQuick 2.0
import SddmComponents 2.0
import "SimpleControls" as Simple

Rectangle {
    
    width: 640
    height: 480
    
    LayoutMirroring.enabled: Qt.locale().textDirection == Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    TextConstants { id: textConstants }
    
    Connections {
        target: sddm
        onLoginSucceeded: {}
        onLoginFailed: {
            pw_entry.text = ""
            pw_entry.focus = true
        }
    }
    
    Background {
        anchors.fill: parent
        source: config.background
        fillMode: Image.PreserveAspectCrop
        onStatusChanged: {
            if (status == Image.Error && source != config.defaultBackground) {
                source = config.defaultBackground
            }
        }
    }
    
    Rectangle {
        anchors.fill: parent
        color: "transparent"

        Rectangle {
            width: 400
            height: 250
            color: "transparent"
            anchors.centerIn: parent
            anchors.verticalCenterOffset: height / 2

            Rectangle {
                id: entries
                width: parent.width
                height: 200
                color: "transparent"
                radius: 4
                
                Column {
                    anchors.centerIn: parent
                    spacing: 20
     
                    Row {
                        TextBox {
                            id: user_entry
                            radius: 3
                            width: 250
                            anchors.verticalCenter: parent.verticalCenter
                            text: userModel.lastUser
                            font.pixelSize: 16
                            color: Qt.rgba(0, 0, 0, 0.2)
                            borderColor: "transparent"
                            focusColor: Qt.rgba(0, 0, 0, 0.25)
                            hoverColor: Qt.rgba(0, 0, 0, 0.2)
                            textColor: "white"
                            KeyNavigation.backtab: session; KeyNavigation.tab: pw_entry
                        }                   
                    }
                    
                    Row {
                        PasswordBox {
                            id: pw_entry
                            radius: 3
                            width: 250
                            anchors.verticalCenter: parent.verticalCenter
                            font.pixelSize: 15
                            color: Qt.rgba(0, 0, 0, 0.2)
                            borderColor: "transparent"
                            focusColor: Qt.rgba(0, 0, 0, 0.25)
                            hoverColor: Qt.rgba(0, 0, 0, 0.2)
                            textColor: "white"
                            focus: true
                            KeyNavigation.backtab: user_entry; KeyNavigation.tab: loginButton

                            Keys.onPressed: {
                                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                    sddm.login(user_entry.text, pw_entry.text, session.index)
                                    event.accepted = true
                                }
                            }
                        }
                    }
                      
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        
                        Button {
                            id: loginButton
                            radius: 3
                            text: textConstants.login
                            width: 250
                            color: Qt.rgba(0, 0, 0, 0.2)
                            activeColor: Qt.rgba(0, 0, 0, 0.2)
                            pressedColor: Qt.rgba(0, 0, 0, 0.25)
                            font.pixelSize: 15
                            font.bold: false
                            onClicked: sddm.login(user_entry.text, pw_entry.text, session.index)
                            KeyNavigation.backtab: pw_entry; KeyNavigation.tab: restart
                        }
                    }
                    
                }
                
            }
            
        }
        
    }
    
    Rectangle {
        width: parent.width - 10
        height: 40
        color: "transparent"
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        
        Simple.SimpleComboBox {
            id: session
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: 160
            color: Qt.rgba(0, 0, 0, 0.2)
            dropDownColor: Qt.rgba(0, 0, 0, 0.2)
            borderColor: "transparent"
            textColor: "white"
            arrowIcon: "images/arrow-down.png"
            arrowColor: "transparent"
            model: sessionModel
            index: sessionModel.lastIndex
            font.pixelSize: 13
            KeyNavigation.backtab: shutdown; KeyNavigation.tab: user_entry
        }
        
        Button {
            id: restart
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: shutdown.left
            anchors.rightMargin: 10
            text: textConstants.reboot
            color: Qt.rgba(0, 0, 0, 0.2)
            pressedColor: Qt.rgba(0, 0, 0, 0.25)
            activeColor: Qt.rgba(0, 0, 0, 0.2)
            font.pixelSize: 13
            font.bold: false
            radius: 3
            onClicked: sddm.reboot()
            KeyNavigation.backtab: loginButton; KeyNavigation.tab: shutdown
        }
        
        Button {
            id: shutdown
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            text: textConstants.shutdown
            color: Qt.rgba(0, 0, 0, 0.2)
            pressedColor: Qt.rgba(0, 0, 0, 0.25)
            activeColor: Qt.rgba(0, 0, 0, 0.2)
            font.pixelSize: 13
            font.bold: false
            radius: 3
            onClicked: sddm.powerOff()
            KeyNavigation.backtab: restart; KeyNavigation.tab: session
        }
        
    }
    
    Component.onCompleted: {
        if (user_entry.text === "")
            user_entry.focus = true
        else
            pw_entry.focus = true
    }
}
