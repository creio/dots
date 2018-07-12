import QtQuick 2.0
import SddmComponents 2.0

Row {
  id: powerFrame

  spacing: 5

  anchors {
      bottom: page.bottom
      right: page.right
      rightMargin: 50
      bottomMargin: 50
  }

  Image {
    id: shutdownButton
    width: 64
    height: 64
    source: "Assets/shutdown_normal.png"

    MouseArea {
      id: shutdownArea
      anchors.fill: parent
      hoverEnabled: true

      onClicked: sddm.powerOff();
    }

    //Hover Effect
    Image {
      id: shutdownHover
      anchors.fill: parent
      source: "Assets/shutdown_hover.png"
      opacity: shutdownArea.containsMouse ? 1 : 0

      Behavior on opacity {
        NumberAnimation { duration: 350; easing.type: Easing.InOutQuad}
      }
    }
  }

  Image {
    id: restartButton
    width: 64
    height: 64
    source: "Assets/restart_normal.png"

    MouseArea {
      id: restartArea
      anchors.fill: parent
      hoverEnabled: true

      onClicked: sddm.reboot();
    }

    //Hover Effect
    Image {
      id: restartHover
      anchors.fill: parent
      source: "Assets/restart_hover.png"
      opacity: restartArea.containsMouse ? 1 : 0

      Behavior on opacity {
        NumberAnimation { duration: 350; easing.type: Easing.InOutQuad}
      }
    }
  }

  Image {
    id: sessionButton
    width: 64
    height: 64
    source: "Assets/session_normal.png"

    MouseArea {
      id: sessionArea
      anchors.fill: parent
      hoverEnabled: true

      onClicked: {
        if (sessionSelect.state == "show")
          sessionSelect.state = "";
        else if (sessionSelect.state == "")
          sessionSelect.state = "show";
      }
    }

    //Hover Effect
    Image {
      id: sessionHover
      anchors.fill: parent
      source: "Assets/session_hover.png"
      opacity: sessionArea.containsMouse ? 1 : 0

      Behavior on opacity {
        NumberAnimation { duration: 350; easing.type: Easing.InOutQuad}
      }
    }

  }

}
