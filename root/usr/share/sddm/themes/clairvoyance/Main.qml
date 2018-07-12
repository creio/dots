import QtQuick 2.0
import SddmComponents 2.0

Item {
  id: page
  width: 1920
  height: 1080

  //Put everything below the background or it won't be shown
  Image {
    id: background
    anchors.fill: parent
    source: config.background
  }

  Login {
    id: loginFrame
    visible: false
    opacity: 0
  }

  PowerFrame {
    id: powerFrame
  }


  ListView {
    id: sessionSelect
    width: currentItem.width
    height: count * currentItem.height
    model: sessionModel
    currentIndex: sessionModel.lastIndex
    visible: false
    opacity: 0
    flickableDirection: Flickable.AutoFlickIfNeeded
    anchors {
      bottom: powerFrame.top
      right: page.right
      rightMargin: 35
    }
    delegate: Item {
      width: 100
      height: 50
      Text {
        width: parent.width
        height: parent.height
        text: name
        color: "white"
        opacity: (delegateArea.containsMouse || sessionSelect.currentIndex == index) ? 1 : 0.3
        font {
          pointSize: (config.enableHDPI == "true") ? 6 : 12
          family: "FiraMono"
        }
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        Behavior on opacity {
          NumberAnimation { duration: 250; easing.type: Easing.InOutQuad}
        }
      }

      MouseArea {
        id: delegateArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
          sessionSelect.currentIndex = index
          sessionSelect.state = ""
        }
      }
    }

    states: State {
      name: "show"
      PropertyChanges {
        target: sessionSelect
        visible: true
        opacity: 1
      }
    }

    transitions: [
    Transition {
      from: ""
      to: "show"
      SequentialAnimation {
        PropertyAnimation {
          target: sessionSelect
          properties: "visible"
          duration: 0
        }
        PropertyAnimation {
          target: sessionSelect
          properties: "opacity"
          duration: 500
        }
      }
    },
    Transition {
      from: "show"
      to: ""
      SequentialAnimation {
        PropertyAnimation {
          target: sessionSelect
          properties: "opacity"
          duration: 500
        }
        PropertyAnimation {
          target: sessionSelect
          properties: "visible"
          duration: 0
        }
      }
    }
    ]

  }



  ChooseUser {
    id: listView
    visible: true
    opacity: 1
  }

  states: State {
    name: "login"
    PropertyChanges {
      target: listView
      visible: false
      opacity: 0
    }

    PropertyChanges {
      target: loginFrame
      visible: true
      opacity: 1
    }
  }

  transitions: [
  Transition {
    from: ""
    to: "login"
    reversible: false

    SequentialAnimation {
      PropertyAnimation {
        target: listView
        properties: "opacity"
        duration: 500
      }
      PropertyAnimation {
        target: listView
        properties: "visible"
        duration: 0
      }
      PropertyAnimation {
        target: loginFrame
        properties: "visible"
        duration: 0
      }
      PropertyAnimation {
        target: loginFrame
        properties: "opacity"
        duration: 500
      }
    }
  },
  Transition {
    from: "login"
    to: ""
    reversible: false

    SequentialAnimation {
      PropertyAnimation {
        target: loginFrame
        properties: "opacity"
        duration: 500
      }
      PropertyAnimation {
        target: loginFrame
        properties: "visible"
        duration: 0
      }
      PropertyAnimation {
        target: listView
        properties: "visible"
        duration: 0
      }
      PropertyAnimation {
        target: listView
        properties: "opacity"
        duration: 500
      }
    }
  }]

}
