import QtQuick 2.7

Item
{
    id: pageRoot

    property int selectedIndex: sessionModel.lastIndex
    property string currentSessionName: get_name(0)
    property int scrollRepeat: 0

    function get_relative_index(relate)
    {
        var count = sessionModel.rowCount()
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

    function get_name(relate)
    {
        // Qt.UserRole + 4 is SDDM.NameRole (from src/greeter/SessionModel.h)
        return sessionModel.data(sessionModel.index(get_relative_index(relate), 0), Qt.UserRole + 4)
    }

    signal sessionSelected()

    Item
    {
        id: sessionListContainer
        anchors.horizontalCenter: parent.horizontalCenter

        property int scrollDuration: 100

        MouseArea
        {
            id: topFarItemMouseArea
            onEntered: { topFarItem.hover = true }
            onExited: { topFarItem.hover = false }
            hoverEnabled: true
            x: -225
            width: 450
            height: pageRoot.height / 6

            onClicked: { scrollRepeat = 1; scroll_down(); }

        }

        MouseArea
        {
            id: topMidItemMouseArea
            onEntered: { topMidItem.hover = true }
            onExited: { topMidItem.hover = false }
            y: topFarItemMouseArea.height
            hoverEnabled: true
            x: -225
            width: 450
            height: pageRoot.height / 5

            onClicked: scroll_down()

        }

        MouseArea
        {
            id: middleItemMouseArea
            onEntered: { middleItem.hover = true }
            onExited: { middleItem.hover = false }
            y: topMidItemMouseArea.y + topMidItemMouseArea.height
            hoverEnabled: true
            x: -225
            width: 450
            height: pageRoot.height / 4

            onClicked: pageRoot.sessionSelected()

        }

        MouseArea
        {
            id: botMidItemMouseArea
            onEntered: { botMidItem.hover = true }
            onExited: { botMidItem.hover = false }
            y: middleItemMouseArea.y + middleItemMouseArea.height
            hoverEnabled: true
            x: -225
            width: 450
            height: pageRoot.height / 5

            onClicked: scroll_up()

        }

        MouseArea
        {
            id: botFarItemMouseArea
            onEntered: { botFarItem.hover = true }
            onExited: { botFarItem.hover = false }
            y: botMidItemMouseArea.y + botMidItemMouseArea.height
            hoverEnabled: true
            x: -225
            width: 450
            height: pageRoot.height / 6

            onClicked: { scrollRepeat = 1; scroll_up(); }

        }

        LoopListSessionItem
        {
            id: topFallbackItem
            y: 0
            distance: 0
            sessionName: get_name(-3)
        }

        LoopListSessionItem
        {
            id: topFarItem
            y: pageRoot.height / 18
            distance: 0.33
            sessionName: get_name(-2)
        }

        LoopListSessionItem
        {
            id: topMidItem
            y: pageRoot.height / 4.3
            distance: 0.66
            sessionName: get_name(-1)
        }

        LoopListSessionItem
        {
            id: middleItem
            y: pageRoot.height / 2.1
            sessionName: get_name(0)
        }

        LoopListSessionItem
        {
            id: botMidItem
            y: pageRoot.height / 1.4
            distance: 0.66
            sessionName: get_name(1)
        }

        LoopListSessionItem
        {
            id: botFarItem
            y: pageRoot.height / 1.1
            distance: 0.33
            sessionName: get_name(2)
        }

        LoopListSessionItem
        {
            id: botFallbackItem
            y: pageRoot.height
            distance: 0
            sessionName: get_name(3)
        }

        ParallelAnimation
        {
            id: sessionListScrollUp
            NumberAnimation { target: topFarItem; property: "y"; to: 0; duration: sessionListContainer.scrollDuration }
            NumberAnimation { target: topFarItem; property: "distance"; to: 0; duration: sessionListContainer.scrollDuration }
            
            NumberAnimation { target: topMidItem; property: "y"; to: pageRoot.height / 18; duration: sessionListContainer.scrollDuration }
            NumberAnimation { target: topMidItem; property: "distance"; to: 0.33; duration: sessionListContainer.scrollDuration }

            NumberAnimation { target: middleItem; property: "y"; to: pageRoot.height / 4.3; duration: sessionListContainer.scrollDuration }
            NumberAnimation { target: middleItem; property: "distance"; to: 0.66; duration: sessionListContainer.scrollDuration }

            NumberAnimation { target: botMidItem; property: "y"; to: pageRoot.height / 2.1; duration: sessionListContainer.scrollDuration }
            NumberAnimation { target: botMidItem; property: "distance"; to: 1; duration: sessionListContainer.scrollDuration }

            NumberAnimation { target: botFarItem; property: "y"; to: pageRoot.height / 1.4; duration: sessionListContainer.scrollDuration }
            NumberAnimation { target: botFarItem; property: "distance"; to: 0.66; duration: sessionListContainer.scrollDuration }

            NumberAnimation { target: botFallbackItem; property: "y"; to: pageRoot.height / 1.1; duration: sessionListContainer.scrollDuration }
            NumberAnimation { target: botFallbackItem; property: "distance"; to: 0.33; duration: sessionListContainer.scrollDuration }

            onStopped:
            {
                if (selectedIndex >= sessionModel.rowCount() - 1)
                    selectedIndex = 0
                else
                    selectedIndex++

                reset_items()

                if (scrollRepeat > 0)
                {
                    scrollRepeat--
                    sessionListScrollUp.start()
                }
            }
        }

        ParallelAnimation
        {
            id: sessionListScrollDown
            NumberAnimation { target: topFallbackItem; property: "y"; to: pageRoot.height / 18; duration: sessionListContainer.scrollDuration }
            NumberAnimation { target: topFallbackItem; property: "distance"; to: 0.33; duration: sessionListContainer.scrollDuration }

            NumberAnimation { target: topFarItem; property: "y"; to: pageRoot.height / 4.3; duration: sessionListContainer.scrollDuration }
            NumberAnimation { target: topFarItem; property: "distance"; to: 0.66; duration: sessionListContainer.scrollDuration }
            
            NumberAnimation { target: topMidItem; property: "y"; to: pageRoot.height / 2.1; duration: sessionListContainer.scrollDuration }
            NumberAnimation { target: topMidItem; property: "distance"; to: 1; duration: sessionListContainer.scrollDuration }

            NumberAnimation { target: middleItem; property: "y"; to: pageRoot.height / 1.4; duration: sessionListContainer.scrollDuration }
            NumberAnimation { target: middleItem; property: "distance"; to: 0.66; duration: sessionListContainer.scrollDuration }

            NumberAnimation { target: botMidItem; property: "y"; to: pageRoot.height / 1.1; duration: sessionListContainer.scrollDuration }
            NumberAnimation { target: botMidItem; property: "distance"; to: 0.33; duration: sessionListContainer.scrollDuration }

            NumberAnimation { target: botFarItem; property: "y"; to: pageRoot.height; duration: sessionListContainer.scrollDuration }
            NumberAnimation { target: botFarItem; property: "distance"; to: 0; duration: sessionListContainer.scrollDuration }

            onStopped:
            {
                if (selectedIndex <= 0)
                    selectedIndex = sessionModel.rowCount() - 1
                else
                    selectedIndex--
                
                reset_items()

                if (scrollRepeat > 0)
                {
                    scrollRepeat--
                    sessionListScrollDown.start()
                }
            }
        }
    }

    function reset_items()
    {
        topFallbackItem.y = 0
        topFallbackItem.distance = 0

        topFarItem.y = pageRoot.height / 18
        topFarItem.distance = 0.33

        topMidItem.y = pageRoot.height / 4.3
        topMidItem.distance = 0.66

        middleItem.y = pageRoot.height / 2.1
        middleItem.distance = 1

        botMidItem.y = pageRoot.height / 1.4
        botMidItem.distance = 0.66

        botFarItem.y = pageRoot.height / 1.1
        botFarItem.distance = 0.33

        botFallbackItem.y = pageRoot.height
        botFallbackItem.distance = 0
    }

    function scroll_up()
    {
        sessionListScrollUp.start()
    }

    function scroll_down()
    {
        sessionListScrollDown.start()
    }

    Keys.onUpPressed: scroll_down()
    Keys.onDownPressed: scroll_up()
    Keys.onEnterPressed: pageRoot.sessionSelected()
    Keys.onReturnPressed: pageRoot.sessionSelected()

}