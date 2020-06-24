import QtQuick 2.7
import QtGraphicalEffects 1.0

Item
{
    id: itemRoot
    opacity: distance
    property int duration: 100
    width: parent.width
    property bool hover: false

    signal clicked()
    signal entered()

    transform: Scale
    {
        origin.x: descriptionLabel.height + 10 + 2
        origin.y: descriptionLabel.height + 10 / 2
        xScale: distance
        yScale: distance
    }

    Behavior on distance
    {
        PropertyAnimation { duration: itemRoot.duration }
    }

    property real distance: 1.0
    property string icon: "icons/no_avatar.svg"
    property string title: ""

    Rectangle
    {
        width: descriptionLabel.height + 10
        height: descriptionLabel.height + 10
        color: ( hover ? colors.iconBgHover : colors.iconBg )
    }

    Image
    {
        id: powerItemIcon
        source: icon
        sourceSize.width: descriptionLabel.height + 10 - 4
        sourceSize.height: descriptionLabel.height + 10 - 4
        x: 2
        y: 2
        opacity: 0
    }

    ColorOverlay
    {
        id: powerItemIconOverlay
        anchors.fill: powerItemIcon
        source: powerItemIcon
        color: ( hover ? colors.iconHover : colors.icon )
        opacity: parent.opacity
    }

    Rectangle
    {
        x: descriptionLabel.height + 10 + 2
        width: parent.width - descriptionLabel.height + 10 - 2
        height: descriptionLabel.height + 10
        color: ( hover ? colors.textBgHover : colors.textBg )
    }

    Text
    {
        id: descriptionLabel
        text: itemRoot.title
        color: ( hover ? colors.textHover : colors.text )
        width: parent.width - descriptionLabel.height + 10 - 2 - 24

        font: fonts.listItemMed
        elide: Text.ElideRight

        x: descriptionLabel.height + 10 + 12
        y: 5
    }

    MouseArea
    {
        width: descriptionLabel.x + descriptionLabel.width
        height: descriptionLabel.height + 10
        hoverEnabled: true

        onClicked: itemRoot.clicked()
        onEntered: itemRoot.entered()
    }
}