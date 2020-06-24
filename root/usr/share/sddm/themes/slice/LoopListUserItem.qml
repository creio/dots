import QtQuick 2.7
import QtGraphicalEffects 1.0
import SddmComponents 2.0

Item
{
    id: itemRoot
    opacity: computedDistance
    width: parent.width
    height: userName == "" ? userLoginText.height + 14 : userNameText.height + userLoginText.height - 4
    
    property bool hover: false
    property bool hoverEnabled: true

    transform: Scale
    {
        origin.x: itemRoot.height + 12
        xScale: computedDistance
        yScale: computedDistance
    }

    property real distance: 1.0
    readonly property real computedDistance: Math.sin(Math.PI / 2 * distance)
    property string userName: ""
    property string userLogin: ""
    property string userAvatar: "icons/no_avatar.svg"

    Rectangle
    {
        width: itemRoot.height
        height: itemRoot.height
        color: ( hoverEnabled && hover ? colors.iconBgHover : colors.iconBg )
    }

    Image
    {
        id: profilePicture
        source: userAvatar
        sourceSize.width: itemRoot.height - 8
        sourceSize.height: itemRoot.height - 8
        x: 4
        y: 4
    }

    Rectangle
    {
        x: itemRoot.height + 2
        y: 0
        width: parent.width - itemRoot.height - 2
        height: itemRoot.height
        color: ( hoverEnabled && hover ? colors.textBgHover : colors.textBg )
    }

    Text
    {
        id: userNameText
        text: userName
        color: ( hoverEnabled && hover ? colors.textHover : colors.text )
        
        font: fonts.listItemMed

        elide: Text.ElideRight

        x: itemRoot.height + 12
        y: 0

        width: itemRoot.width - itemRoot.height - 26
    }

    Text
    {
        id: userLoginText
        text: userLogin
        color: ( hoverEnabled && hover ? (userName == "" ? colors.textHover : colors.textDimmedHover ) : (userName == "" ? colors.text : colors.textDimmed ) )
        y: userName == "" ? 7 : userNameText.height * 0.8
        font: userName == "" ? fonts.listItemBig : fonts.listItemSub
        x: itemRoot.height + 12

        elide: Text.ElideRight

        width: itemRoot.width - itemRoot.height - 26
    }
}