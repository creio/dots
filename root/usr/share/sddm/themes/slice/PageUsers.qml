import QtQuick 2.7

Item
{
    id: pageRoot
    focus: true

    property int selectedIndex: userModel.lastIndex
    property int selectedSessionIndex: sessionModel.lastIndex
    property int scrollRepeat: 0
    property string currentUserLogin: get_login(0)
    property bool hasLoginShown: true
    property bool manual: bool(config.manual)

    signal lockNav()
    signal unlockNav()

    function get_relative_index(relate)
    {
        var count = userModel.count
        if (count <= 0)
            return 0

        var index = selectedIndex + relate

        if (index < 0)
            while (index < 0)
                index = count + index
        else if (index >= count)
            while (index >= count)
                index = index - count

        return index
    }

    function get_login(relate)
    {
        // Qt.UserRole + 1 is SDDM.NameRole (from src/greeter/UserModel.h)
        return userModel.data(userModel.index(get_relative_index(relate), 0), Qt.UserRole + 1)
    }

    function get_name(relate)
    {
        // Qt.UserRole + 2 is SDDM.RealNameRole (from src/greeter/UserModel.h)
        return userModel.data(userModel.index(get_relative_index(relate), 0), Qt.UserRole + 2)
    }

    function get_avatar(relate)
    {
        // Qt.UserRole + 4 is SDDM.IconRole (from src/greeter/UserModel.h)
        return userModel.data(userModel.index(get_relative_index(relate), 0), Qt.UserRole + 4)
    }

    Connections
    {
        target: sddm

        onLoginFailed:
        {
            errorMessage.opacity = 1
            errorMessageBg.opacity = 1
            pageRoot.enabled = true
            pageRoot.unlockNav()
            loginExitAnimation.start()
            passwordField.text = ""
        } 
    }

    onFocusChanged:
    {
        if (focus && hasLoginShown) {
            if (manual)
                loginField.forceActiveFocus()
            else
                passwordField.forceActiveFocus()
        }
    }

    Item
    {
        id: userListContainer
        anchors.horizontalCenter: parent.horizontalCenter
        width: 450

        property int scrollDuration: 100

        MouseArea
        {
            id: topFarItemMouseArea
            onEntered: { topFarItem.hover = true }
            onExited: { topFarItem.hover = false }
            hoverEnabled: true
            width: parent.width
            height: pageRoot.height / 6
            //enabled: !hasLoginShown

            onClicked: { if (!hasLoginShown) { scrollRepeat = 1; scroll_down(); } }

        }

        MouseArea
        {
            id: topMidItemMouseArea
            onEntered: { topMidItem.hover = true }
            onExited: { topMidItem.hover = false }
            y: topFarItemMouseArea.height
            hoverEnabled: true
            width: parent.width
            height: pageRoot.height / 5
            propagateComposedEvents: true
            //enabled: !hasLoginShown

            onClicked: { if (!hasLoginShown) { scroll_down(); } }

        }

        MouseArea
        {
            id: middleItemMouseArea
            onEntered: { middleItem.hover = true }
            onExited: { middleItem.hover = false }
            y: topMidItemMouseArea.y + topMidItemMouseArea.height - (hasLoginShown ? 60 : 0)
            hoverEnabled: true
            width: parent.width
            height: pageRoot.height / 4
            //enabled: !hasLoginShown

            onClicked: { (hasLoginShown ? back_to_selection() : select_or_login()) } 

        }

        MouseArea
        {
            id: botMidItemMouseArea
            onEntered: { botMidItem.hover = true }
            onExited: { botMidItem.hover = false }
            y: middleItemMouseArea.y + middleItemMouseArea.height
            hoverEnabled: true
            width: parent.width
            height: pageRoot.height / 5
            //enabled: !hasLoginShown

            onClicked: { if (!hasLoginShown) { scroll_up(); } }

        }

        MouseArea
        {
            id: botFarItemMouseArea
            onEntered: { botFarItem.hover = true }
            onExited: { botFarItem.hover = false }
            y: botMidItemMouseArea.y + botMidItemMouseArea.height
            hoverEnabled: true
            width: parent.width
            height: pageRoot.height / 6
            //enabled: !hasLoginShown

            onClicked: { if (!hasLoginShown) { scrollRepeat = 1; scroll_up(); } }

        }

        LoopListUserItem
        {
            id: topFallbackItem
            y: 0
            distance: 0
            userName: get_name(-3)
            userLogin: get_login(-3)
            userAvatar: get_avatar(-3)
        }

        LoopListUserItem
        {
            id: topFarItem
            y: pageRoot.height / 18
            distance: hasLoginShown ? 0 : 0.4
            userName: get_name(-2)
            userLogin: get_login(-2)
            userAvatar: get_avatar(-2)
        }

        LoopListUserItem
        {
            id: topMidItem
            y: pageRoot.height / 4.7
            distance: hasLoginShown ? 0 : 0.7
            userName: get_name(-1)
            userLogin: get_login(-1)
            userAvatar: get_avatar(-1)
        }

        LoopListUserItem
        {
            id: middleItem
            y: hasLoginShown ? pageRoot.height / 2.3 - (middleItem.height / 2 + passwordFieldBg.height + progressBar.height + 2 + buttonUserLogin.height) / 2 : pageRoot.height / 2.3
            userName: get_name(0)
            userLogin: get_login(0)
            userAvatar: get_avatar(0)
            visible: !manual
        }

        LoopListUserItem
        {
            id: botMidItem
            y: pageRoot.height / 1.45
            distance: hasLoginShown ? 0 : 0.7
            userName: get_name(1)
            userLogin: get_login(1)
            userAvatar: get_avatar(1)
        }

        LoopListUserItem
        {
            id: botFarItem
            y: pageRoot.height / 1.10
            distance: hasLoginShown ? 0 : 0.4
            userName: get_name(2)
            userLogin: get_login(2)
            userAvatar: get_avatar(2)
        }

        LoopListUserItem
        {
            id: botFallbackItem
            y: pageRoot.height
            distance: 0
            userName: get_name(3)
            userLogin: get_login(3)
            userAvatar: get_avatar(3)
        }

        Item {
            id: loginControls
            y: manual ? middleItem.y : middleItem.y + middleItem.height + 2
            width: parent.width

            Rectangle
            {
                id: loginFieldBg
                y: 0
                width: parent.width
                height: Math.max(fonts.input.pointSize, fonts.placeholder.pointSize) + 20
                opacity: hasLoginShown && manual ? 1 : 0
                color: colors.inputBg
            }

            TextInput
            {
                id: loginField
                x: 10
                y: (loginFieldBg.height - height) / 2 + loginFieldBg.y
                width: parent.width - 20
                opacity: hasLoginShown && manual ? 1 : 0
                color: colors.inputText
                selectionColor: colors.inputSelectionBg
                selectedTextColor: colors.inputSelectionText

                clip: true
                selectByMouse: true
                
                font: fonts.loginInput

                Component.onCompleted: if (manual) forceActiveFocus()
                Keys.onTabPressed: passwordField.forceActiveFocus()
            }

            Text
            {
                id: loginFieldPlaceholder
                x: loginField.x
                y: (loginFieldBg.height - height) / 2 + loginFieldBg.y
                width: loginField.width
                opacity: hasLoginShown && manual ? 1 : 0
                visible: loginField.text.length <= 0

                color: colors.inputPlaceholderText

                font: fonts.placeholder

                text: localeText.userName
            }

            Rectangle
            {
                id: passwordFieldBg
                y: manual ? loginFieldBg.y + loginFieldBg.height + 2 : 0
                width: parent.width
                height: Math.max(fonts.input.pointSize, fonts.placeholder.pointSize) + 20
                opacity: hasLoginShown ? 1 : 0
                color: colors.inputBg
            }

            TextInput
            {
                id: passwordField
                x: 10
                y: (passwordFieldBg.height - height) / 2 + passwordFieldBg.y
                width: parent.width - 20
                opacity: hasLoginShown ? 1 : 0
                color: colors.inputText
                selectionColor: colors.inputSelectionBg
                selectedTextColor: colors.inputSelectionText

                echoMode: TextInput.Password
                clip: true
                selectByMouse: true
                
                font: fonts.input

                Component.onCompleted: forceActiveFocus()
                Keys.onBacktabPressed: { if (manual) loginField.forceActiveFocus(); else event.accepted = false; }

            }

            Text
            {
                id: passwordFieldPlaceholder
                x: passwordField.x
                y: (passwordFieldBg.height - height) / 2 + passwordFieldBg.y
                width: passwordField.width
                opacity: hasLoginShown ? 1 : 0
                visible: passwordField.text.length <= 0

                color: colors.inputPlaceholderText

                font: fonts.placeholder

                text: localeText.password
            }

            Rectangle
            {
                id: progressBar
                y: passwordFieldBg.y + passwordFieldBg.height
                width: parent.width
                height: 2
                opacity: hasLoginShown ? 1 : 0
                color: colors.progressBar
            }

            Rectangle
            {
                id: progressBarBg
                y: progressBar.y
                width: parent.width
                height: 2
                opacity: 0
                color: colors.progressBarBg
            }

            Rectangle
            {
                id: progressBarSlider1
                x: 0
                y: progressBar.y
                width: parent.width / 5
                height: 2
                opacity: 0
                color: colors.progressBarSlider
            }

            Rectangle
            {
                id: progressBarSlider2
                x: parent.width
                y: progressBar.y
                width: 0
                height: 2
                opacity: 0
                color: colors.progressBarSlider
            }

            SlicedButton
            {
                id: buttonUserLogin
                x: userListContainer.width - widthFull
                y: progressBar.y + progressBar.height + 2
                paddingTop: 2
                highlighted: true
                opacity: hasLoginShown ? 1 : 0

                text: localeText.login

                onClicked: select_or_login()

                font: fonts.slicesLoginButtons
            }

            SlicedButton
            {
                id: buttonUserBack
                x: userListContainer.width - widthFull - buttonUserLogin.widthPartial - 3
                y: buttonUserLogin.y
                paddingTop: 2
                opacity: hasLoginShown ? 1 : 0
                visible: !manual

                text: qsTr("Back")

                onClicked: back_to_selection()

                font: fonts.slicesLoginButtons
            }

        }

        Rectangle
        {
            id: errorMessageBg
            x: errorMessage.x - 10
            y: errorMessage.y - 5
            width: errorMessage.width + 20
            height: errorMessage.height + 10
            color: colors.errorBg
            opacity: 0

            Behavior on opacity { NumberAnimation { duration: userListContainer.scrollDuration } }
        }

        Text
        {
            id: errorMessage
            text: localeText.loginFailed
            anchors.horizontalCenter: parent.horizontalCenter
            y: pageRoot.height / 4.7
            opacity: 0

            color: colors.errorText

            font: fonts.error

            Behavior on opacity { NumberAnimation { duration: userListContainer.scrollDuration } }

        }

        ParallelAnimation
        {
            id: progressBarLoop
            loops: Animation.Infinite
            SequentialAnimation
            {
                NumberAnimation { target: progressBarSlider1; property: "x"; to: userListContainer.width - userListContainer.width / 5; duration: 400 }
                ParallelAnimation
                {
                    NumberAnimation { target: progressBarSlider1; property: "x"; to: userListContainer.width; duration: 100 }
                    NumberAnimation { target: progressBarSlider1; property: "width"; to: 0; duration: 100 }
                }
                NumberAnimation { target: progressBarSlider1; property: "x"; to: 0; duration: 500 }
                NumberAnimation { target: progressBarSlider1; property: "width"; to: userListContainer.width / 5; duration: 100 }
            }

            SequentialAnimation
            {
                NumberAnimation { target: progressBarSlider2; property: "x"; to: 0; duration: 500 }
                NumberAnimation { target: progressBarSlider2; property: "width"; to: userListContainer.width / 5; duration: 100 }
                NumberAnimation { target: progressBarSlider2; property: "x"; to: userListContainer.width - userListContainer.width / 5; duration: 400 }
                ParallelAnimation
                {
                    NumberAnimation { target: progressBarSlider2; property: "x"; to: userListContainer.width; duration: 100 }
                    NumberAnimation { target: progressBarSlider2; property: "width"; to: 0; duration: 100 }
                }
            }

            onStopped: 
            {
                progressBarSlider1.x = 0
                progressBarSlider1.width = userListContainer.width / 5
                progressBarSlider2.x = userListContainer.width
                progressBarSlider2.width = 0
            }
        }

        ParallelAnimation
        {
            id: userListHideOther
            NumberAnimation { target: topFarItem; property: "distance"; to: 0; duration: userListContainer.scrollDuration }
            NumberAnimation { target: topMidItem; property: "distance"; to: 0; duration: userListContainer.scrollDuration }
            NumberAnimation { target: botMidItem; property: "distance"; to: 0; duration: userListContainer.scrollDuration }
            NumberAnimation { target: botFarItem; property: "distance"; to: 0; duration: userListContainer.scrollDuration }

            NumberAnimation { target: middleItem; property: "y"; to: pageRoot.height / 2.3 - (middleItem.height / 2 + passwordFieldBg.height + progressBar.height + 2 + buttonUserLogin.height) / 2; duration: userListContainer.scrollDuration }

            NumberAnimation { target: loginField; property: "opacity"; to: 1; duration: userListContainer.scrollDuration }
            NumberAnimation { target: loginFieldPlaceholder; property: "opacity"; to: 1; duration: userListContainer.scrollDuration }
            NumberAnimation { target: loginFieldBg; property: "opacity"; to: 1; duration: userListContainer.scrollDuration }
            NumberAnimation { target: passwordField; property: "opacity"; to: 1; duration: userListContainer.scrollDuration }
            NumberAnimation { target: passwordFieldPlaceholder; property: "opacity"; to: 1; duration: userListContainer.scrollDuration }
            NumberAnimation { target: passwordFieldBg; property: "opacity"; to: 1; duration: userListContainer.scrollDuration }
            NumberAnimation { target: progressBar; property: "opacity"; to: 1; duration: userListContainer.scrollDuration }
            NumberAnimation { target: buttonUserBack; property: "opacity"; to: 1; duration: userListContainer.scrollDuration }
            NumberAnimation { target: buttonUserLogin; property: "opacity"; to: 1; duration: userListContainer.scrollDuration }

            onStopped: 
            {
                hasLoginShown = true
                passwordField.forceActiveFocus()
            }
        }

        ParallelAnimation
        {
            id: userListShowOther
            NumberAnimation { target: topFarItem; property: "distance"; to: 0.4; duration: userListContainer.scrollDuration }
            NumberAnimation { target: topMidItem; property: "distance"; to: 0.7; duration: userListContainer.scrollDuration }
            NumberAnimation { target: botMidItem; property: "distance"; to: 0.7; duration: userListContainer.scrollDuration }
            NumberAnimation { target: botFarItem; property: "distance"; to: 0.4; duration: userListContainer.scrollDuration }

            NumberAnimation { target: middleItem; property: "y"; to: pageRoot.height / 2.3; duration: userListContainer.scrollDuration }

            NumberAnimation { target: loginField; property: "opacity"; to: 0; duration: userListContainer.scrollDuration }
            NumberAnimation { target: loginFieldPlaceholder; property: "opacity"; to: 0; duration: userListContainer.scrollDuration }
            NumberAnimation { target: loginFieldBg; property: "opacity"; to: 0; duration: userListContainer.scrollDuration }
            NumberAnimation { target: passwordField; property: "opacity"; to: 0; duration: userListContainer.scrollDuration }
            NumberAnimation { target: passwordFieldPlaceholder; property: "opacity"; to: 0; duration: userListContainer.scrollDuration }
            NumberAnimation { target: passwordFieldBg; property: "opacity"; to: 0; duration: userListContainer.scrollDuration }
            NumberAnimation { target: progressBar; property: "opacity"; to: 0; duration: userListContainer.scrollDuration }
            NumberAnimation { target: buttonUserBack; property: "opacity"; to: 0; duration: userListContainer.scrollDuration }
            NumberAnimation { target: buttonUserLogin; property: "opacity"; to: 0; duration: userListContainer.scrollDuration }

            onStopped:
            {
                hasLoginShown = false
                pageRoot.focus = true
            }
        }

        ParallelAnimation
        {
            id: userListScrollUp
            NumberAnimation { target: topFarItem; property: "y"; to: 0; duration: userListContainer.scrollDuration }
            NumberAnimation { target: topFarItem; property: "distance"; to: 0; duration: userListContainer.scrollDuration }
            
            NumberAnimation { target: topMidItem; property: "y"; to: pageRoot.height / 18; duration: userListContainer.scrollDuration }
            NumberAnimation { target: topMidItem; property: "distance"; to: 0.4; duration: userListContainer.scrollDuration }

            NumberAnimation { target: middleItem; property: "y"; to: pageRoot.height / 4.7; duration: userListContainer.scrollDuration }
            NumberAnimation { target: middleItem; property: "distance"; to: 0.7; duration: userListContainer.scrollDuration }

            NumberAnimation { target: botMidItem; property: "y"; to: pageRoot.height / 2.3; duration: userListContainer.scrollDuration }
            NumberAnimation { target: botMidItem; property: "distance"; to: 1; duration: userListContainer.scrollDuration }

            NumberAnimation { target: botFarItem; property: "y"; to: pageRoot.height / 1.45; duration: userListContainer.scrollDuration }
            NumberAnimation { target: botFarItem; property: "distance"; to: 0.7; duration: userListContainer.scrollDuration }

            NumberAnimation { target: botFallbackItem; property: "y"; to: pageRoot.height / 1.10; duration: userListContainer.scrollDuration }
            NumberAnimation { target: botFallbackItem; property: "distance"; to: 0.4; duration: userListContainer.scrollDuration }

            onStopped:
            {
                if (selectedIndex >= userModel.count - 1)
                    selectedIndex = 0
                else
                    selectedIndex++

                reset_items()

                if (scrollRepeat > 0)
                {
                    scrollRepeat--
                    userListScrollUp.start()
                }
            }
        }

        ParallelAnimation
        {
            id: userListScrollDown
            NumberAnimation { target: topFallbackItem; property: "y"; to: pageRoot.height / 18; duration: userListContainer.scrollDuration }
            NumberAnimation { target: topFallbackItem; property: "distance"; to: 0.4; duration: userListContainer.scrollDuration }

            NumberAnimation { target: topFarItem; property: "y"; to: pageRoot.height / 4.7; duration: userListContainer.scrollDuration }
            NumberAnimation { target: topFarItem; property: "distance"; to: 0.7; duration: userListContainer.scrollDuration }
            
            NumberAnimation { target: topMidItem; property: "y"; to: pageRoot.height / 2.3; duration: userListContainer.scrollDuration }
            NumberAnimation { target: topMidItem; property: "distance"; to: 1; duration: userListContainer.scrollDuration }

            NumberAnimation { target: middleItem; property: "y"; to: pageRoot.height / 1.45; duration: userListContainer.scrollDuration }
            NumberAnimation { target: middleItem; property: "distance"; to: 0.7; duration: userListContainer.scrollDuration }

            NumberAnimation { target: botMidItem; property: "y"; to: pageRoot.height / 1.10; duration: userListContainer.scrollDuration }
            NumberAnimation { target: botMidItem; property: "distance"; to: 0.4; duration: userListContainer.scrollDuration }

            NumberAnimation { target: botFarItem; property: "y"; to: pageRoot.height; duration: userListContainer.scrollDuration }
            NumberAnimation { target: botFarItem; property: "distance"; to: 0; duration: userListContainer.scrollDuration }

            onStopped:
            {
                if (selectedIndex <= 0)
                    selectedIndex = userModel.count - 1
                else
                    selectedIndex--
                
                reset_items()

                if (scrollRepeat > 0)
                {
                    scrollRepeat--
                    userListScrollDown.start()
                }
            }
        }

        ParallelAnimation
        {
            id: loginEnterAnimation
            NumberAnimation { target: passwordField; property: "opacity"; to: 0; duration: userListContainer.scrollDuration }
            NumberAnimation { target: passwordFieldBg; property: "height"; to: 0; duration: userListContainer.scrollDuration }
            NumberAnimation { target: loginControls; property: "y"; to: pageRoot.height / 2.3 - (middleItem.height / 2 + progressBar.height + 2) / 2; duration: userListContainer.scrollDuration }
            NumberAnimation { target: passwordFieldPlaceholder; property: "opacity"; to: 0; duration: userListContainer.scrollDuration }
            NumberAnimation { target: buttonUserBack; property: "opacity"; to: 0; duration: userListContainer.scrollDuration }
            NumberAnimation { target: buttonUserLogin; property: "opacity"; to: 0; duration: userListContainer.scrollDuration }
            NumberAnimation { target: progressBar; property: "opacity"; to: 0; duration: userListContainer.scrollDuration }
            NumberAnimation { target: progressBarSlider1; property: "opacity"; to: 1; duration: userListContainer.scrollDuration }
            NumberAnimation { target: progressBarSlider2; property: "opacity"; to: 1; duration: userListContainer.scrollDuration }
            NumberAnimation { target: progressBarBg; property: "opacity"; to: 1; duration: userListContainer.scrollDuration }
            NumberAnimation { target: middleItem; property: "y"; to: pageRoot.height / 2.3; duration: userListContainer.scrollDuration }

        }

        ParallelAnimation
        {
            id: loginExitAnimation
            NumberAnimation { target: passwordField; property: "opacity"; to: 1; duration: userListContainer.scrollDuration }
            NumberAnimation { target: passwordFieldBg; property: "height"; to: 40; duration: userListContainer.scrollDuration }
            NumberAnimation { target: loginControls; property: "y"; to: pageRoot.height / 2.3 - (middleItem.height / 2 + passwordFieldBg.height + progressBar.height + 2 + buttonUserLogin.height) / 2; duration: userListContainer.scrollDuration }
            NumberAnimation { target: passwordFieldPlaceholder; property: "opacity"; to: 1; duration: userListContainer.scrollDuration }
            NumberAnimation { target: buttonUserBack; property: "opacity"; to: 1; duration: userListContainer.scrollDuration }
            NumberAnimation { target: buttonUserLogin; property: "opacity"; to: 1; duration: userListContainer.scrollDuration }
            NumberAnimation { target: progressBar; property: "opacity"; to: 1; duration: userListContainer.scrollDuration }
            NumberAnimation { target: progressBarSlider1; property: "opacity"; to: 0; duration: userListContainer.scrollDuration }
            NumberAnimation { target: progressBarSlider2; property: "opacity"; to: 0; duration: userListContainer.scrollDuration }
            NumberAnimation { target: progressBarBg; property: "opacity"; to: 0; duration: userListContainer.scrollDuration }
            NumberAnimation { target: middleItem; property: "y"; to: pageRoot.height / 2.3 - (middleItem.height / 2 + passwordFieldBg.height + progressBar.height + 2 + buttonUserLogin.height) / 2; duration: userListContainer.scrollDuration }

            onStopped:
            {
                progressBarLoop.stop()
            }
        }
    }

    function reset_items()
    {
        topFallbackItem.y = 0
        topFallbackItem.distance = 0

        topFarItem.y = pageRoot.height / 18
        topFarItem.distance = 0.4

        topMidItem.y = pageRoot.height / 4.7
        topMidItem.distance = 0.7

        middleItem.y = pageRoot.height / 2.3
        middleItem.distance = 1

        botMidItem.y = pageRoot.height / 1.45
        botMidItem.distance = 0.7

        botFarItem.y = pageRoot.height / 1.10
        botFarItem.distance = 0.4

        botFallbackItem.y = pageRoot.height
        botFallbackItem.distance = 0
    }

    function scroll_up()
    {
        if (!hasLoginShown)
            userListScrollUp.start()
    }

    function scroll_down()
    {
        if (!hasLoginShown)
            userListScrollDown.start()
    }

    function select_or_login()
    {
        if (hasLoginShown)
        {
            middleItem.hoverEnabled = false
            errorMessage.opacity = 0
            errorMessageBg.opacity = 0
            pageRoot.lockNav()
            pageRoot.enabled = false
            progressBarLoop.start()
            loginEnterAnimation.start()
            if (debug.loginError)
                loginTimeoutTimer.start()
            else {
                if (manual)
                    sddm.login(loginField.text, passwordField.text, selectedSessionIndex)
                else
                    sddm.login(currentUserLogin, passwordField.text, selectedSessionIndex)
            }
        }
        else if (!manual)
        {
            topFarItem.hoverEnabled = false
            topMidItem.hoverEnabled = false
            middleItem.hoverEnabled = true
            botMidItem.hoverEnabled = false
            botFarItem.hoverEnabled = false
            userListHideOther.start()
        }
    }

    function back_to_selection()
    {
        if (hasLoginShown && !manual)
        {
            topFarItem.hoverEnabled = true
            topMidItem.hoverEnabled = true
            middleItem.hoverEnabled = true
            botMidItem.hoverEnabled = true
            botFarItem.hoverEnabled = true
            userListShowOther.start()
            errorMessage.opacity = 0
            errorMessageBg.opacity = 0
        }
    }

    Timer
    {
        id: loginTimeoutTimer
        interval: debug.loginTimeout * 1000
        onTriggered: sddm.onLoginFailed()
    }

    Keys.onUpPressed: {
        if (manual && hasLoginShown && passwordField.activeFocus) {
            loginField.forceActiveFocus()
        } else
            scroll_down()
    }
    Keys.onDownPressed: {
        if (manual && hasLoginShown && loginField.activeFocus) {
            passwordField.forceActiveFocus()
        } else
            scroll_up()
    }
    Keys.onEnterPressed: {
        if (hasLoginShown && !passwordField.activeFocus)
            passwordField.forceActiveFocus()
        else
            select_or_login()
    }
    Keys.onReturnPressed: {
        if (hasLoginShown && !passwordField.activeFocus)
            passwordField.forceActiveFocus()
        else
            select_or_login()
    }
    Keys.onEscapePressed: back_to_selection()
    
}