import QtQuick 2.0

ListView {
  height: currentItem.height + 100
  width: this.count * currentItem.width
  model: userModel
  delegate: UserDelegate {}
  currentIndex: userModel.lastIndex
  orientation: ListView.Horizontal
  flickableDirection: Flickable.AutoFlickIfNeeded

  anchors {
    horizontalCenter: parent.horizontalCenter
    verticalCenter: parent.verticalCenter
  }

  focus: true
  clip: true

  Keys.onReturnPressed: {
    page.state = "login";
    loginFrame.name = currentItem.name
    loginFrame.realName = currentItem.realName
    loginFrame.icon = currentItem.icon
    focus = false
	
	if (config.autoFocusPassword == "true")
	  focusDelay.start();
	else
	  loginFrame.focus = true;
  }

  Timer {
    id: focusDelay
	interval: 500
	running: false
	repeat: false

	onTriggered: {
      loginFrame.focusPassword();
	}
  }

  Image {
    id: selector
    width: 32
    height: 32
    source: "Assets/Selector.png"
    x: listView.currentItem.x + (listView.currentItem.width / 2) - 16
    y: listView.currentItem.y + listView.currentItem.height

    Behavior on x {
      NumberAnimation { duration: 350; easing.type: Easing.InOutQuad}
    }
  }

}
