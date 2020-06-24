import QtQuick 2.7
import QtGraphicalEffects 1.0
import SddmComponents 2.0

Item
{
    id: itemRoot
    opacity: computedDistance
    scale: computedDistance

    property real distance: 1.0
    readonly property real computedDistance: Math.sin(Math.PI / 2 * distance)
    property string sessionName: ""
    property bool hover: false

    Rectangle
    {
        x: sessionNameLabel.x - 10
        y: sessionNameLabel.y - 5
        width: sessionNameLabel.width + 20
        height: sessionNameLabel.height + 10
        color: ( hover ? colors.textBgHover : colors.textBg )
    }

    Text
    {
        id: sessionNameLabel
        anchors.centerIn: parent
        text: sessionName
        color: ( hover ? colors.textHover : colors.text )

        font: fonts.listItemMed

        x: parent.x + 10
        y: 5
    }
}