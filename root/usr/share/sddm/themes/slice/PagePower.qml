import QtQuick 2.7
import QtGraphicalEffects 1.0
import SddmComponents 2.0
import QtQuick.Layouts 1.3


Item
{
    id: pageRoot

    property int selectedIndex:
    {
        if (debug.canPowerOff) return 0
        else if (debug.canReboot) return 1
        else if (debug.canSuspend) return 2
        else if (debug.canHibernate) return 3
        else if (debug.canHybridSleep) return 4
        else return 0
    }

    function execute()
    {
        switch (selectedIndex)
        {
            case 0:
                sddm.powerOff();
                break;

            case 1:
                sddm.reboot();
                break;

            case 2:
                sddm.suspend();
                break;

            case 3:
                sddm.hibernate();
                break;

            case 4:
                sddm.hybridSleep();
                break;
        }
    }
    
    ColumnLayout
    {
        id: powerListContainer
        anchors.horizontalCenter: parent.horizontalCenter
        width: 370
        height: pageRoot.height

        property int scrollDuration: 100

        LoopListPowerItem
        {
            id: powerShutdownButton
            title: localeText.shutdown
            distance: selectedIndex == 0 ? 1.0 : 0.6
            hover: selectedIndex == 0
            icon: "icons/power-off.svg"

            Layout.alignment: Qt.AlignVCenter
            Layout.minimumHeight: 48

            visible: debug.canPowerOff
            onEntered: selectedIndex = 0
            onClicked: { selectedIndex = 0; execute() }
        }

        LoopListPowerItem
        {
            id: powerRebootButton
            title: localeText.reboot
            distance: selectedIndex == 1 ? 1.0 : 0.6
            hover: selectedIndex == 1
            icon: "icons/reboot.svg"

            Layout.alignment: Qt.AlignVCenter
            Layout.minimumHeight: 48

            visible: debug.canReboot

            onEntered: selectedIndex = 1
            onClicked: { selectedIndex = 1; execute() }

        }

        LoopListPowerItem
        {
            id: powerSuspendButton
            title: qsTr("Suspend")
            distance: selectedIndex == 2 ? 1.0 : 0.6
            hover: selectedIndex == 2
            icon: "icons/suspend.svg"

            Layout.alignment: Qt.AlignVCenter
            Layout.minimumHeight: 48

            visible: debug.canSuspend

            onEntered: selectedIndex = 2
            onClicked: { selectedIndex = 2; execute() }
        }

        LoopListPowerItem
        {
            id: powerHibernateButton
            title: qsTr("Hibernate")
            distance: selectedIndex == 3 ? 1.0 : 0.6
            hover: selectedIndex == 3
            icon: "icons/hibernate.svg"

            Layout.alignment: Qt.AlignVCenter
            Layout.minimumHeight: 48

            visible: debug.canHibernate

            onEntered: selectedIndex = 3
            onClicked: { selectedIndex = 3; execute() }
        }

        LoopListPowerItem
        {
            id: powerHybridSleepButton
            title: qsTr("Hybrid Sleep")
            distance: selectedIndex == 4 ? 1.0 : 0.6
            hover: selectedIndex == 4
            icon: "icons/hybrid-sleep.svg"

            //Layout.fillHeight: true
            Layout.alignment: Qt.AlignVCenter
            Layout.minimumHeight: 48

            visible: debug.canHybridSleep

            onEntered: selectedIndex = 4
            onClicked: { selectedIndex = 4; execute() }
        }
    }

    function scroll_up()
    {
        selectedIndex = next_index(selectedIndex)
    }

    function scroll_down()
    {
        selectedIndex = prev_index(selectedIndex)
    }

    function next_index(index)
    {
        var result = index
        var actionFound = false


        while (!actionFound)
        {
            if (result >= 4)
                result = 0
            else
                result++

            if (result == index) break

            switch (result)
            {
                case 0:
                    if (debug.canPowerOff) actionFound = true
                    break

                case 1:
                    if (debug.canReboot) actionFound = true
                    break

                case 2:
                    if (debug.canSuspend) actionFound = true
                    break

                case 3:
                    if (debug.canHibernate) actionFound = true
                    break

                case 4:
                    if (debug.canHybridSleep) actionFound = true
                    break
            }

        }

        return result
    }

    function prev_index(index)
    {
        var result = index
        var actionFound = false


        while (!actionFound)
        {
            if (result <= 0)
                result = 4
            else
                result--

            if (result == index) break

            switch (result)
            {
                case 0:
                    if (debug.canPowerOff) actionFound = true
                    break

                case 1:
                    if (debug.canReboot) actionFound = true
                    break

                case 2:
                    if (debug.canSuspend) actionFound = true
                    break

                case 3:
                    if (debug.canHibernate) actionFound = true
                    break

                case 4:
                    if (debug.canHybridSleep) actionFound = true
                    break
            }

        }

        return result
    }

    Keys.onUpPressed: scroll_down()
    Keys.onDownPressed: scroll_up()
    Keys.onEnterPressed: execute()
    Keys.onReturnPressed: execute()
}