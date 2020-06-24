import QtQuick 2.7

Item
{
    id: buttonRoot
    height: paddingTop * 2 + buttonText.height

    property font font: Qt.font({
        family: config.font,
        bold: true,
        pointSize: 13,
        capitalization: Font.AllUppercase,
        smooth: false
    });

    property string text: ""

    property bool highlighted: false
    property int skewLeft:  15
    property int skewRight: 15

    readonly property int paddingLeft: Math.max(Math.abs(skewLeft), 5)
    property int paddingTop: 3
    readonly property int paddingRight: Math.max(Math.abs(skewRight), 5)

    readonly property int widthFull: buttonText.width + paddingLeft + paddingRight
    readonly property int widthPartial: buttonText.width + paddingLeft

    property color bgIdle: colors.buttonBg
    property color bgHover: colors.buttonBgHover

    property color bgIdleHighlighted: colors.buttonBgHighlighted
    property color bgHoverHighlighted: colors.buttonBgHoverHighlighted

    property color textIdle: colors.buttonText
    property color textHover: colors.buttonTextHover

    property color textIdleHighlighted: colors.buttonTextHighlighted
    property color textHoverHighlighted: colors.buttonTextHoverHighlighted


    signal clicked()

    Behavior on x
    {
        PropertyAnimation { duration: 100 }
    }

    onHighlightedChanged:
    {
        buttonBg.requestPaint()
    }

    onTextChanged:
    {
        buttonText.text = buttonRoot.text
    }

    state: "idle"
    states:
    [
        State
        {
            name: "idle"
            PropertyChanges
            {
                target: buttonBg;
                bgColor: highlighted ? bgIdleHighlighted : bgIdle
            }

            PropertyChanges
            {
                target: buttonText;
                color: highlighted ? textIdleHighlighted : textIdle
            }
        },
        State
        {
            name: "hover"
            PropertyChanges
            {
                target: buttonBg;
                bgColor: highlighted ? bgHoverHighlighted : bgHover
            }

            PropertyChanges
            {
                target: buttonText;
                color: highlighted ? textHoverHighlighted : textHover
            }
        }
    ]

    Canvas
    {
        id: buttonBg

        width: widthFull
        height: parent.height
        property string bgColor: colors.buttonBg

        onPaint:
        {
            var context = getContext("2d");
            context.clearRect(0, 0, width, height);
            context.fillStyle = bgColor
            context.beginPath()

            context.moveTo(paddingLeft, height);

            if (skewLeft > 0) {
                context.lineTo(0, height);
                context.lineTo(skewLeft, 0);
            } else if (skewLeft < 0) {
                context.lineTo(Math.abs(skewLeft), height);
                context.lineTo(0, 0);
            } else {
                context.lineTo(0, height);
                context.lineTo(0, 0);
            }

            context.lineTo(widthPartial, 0);

            if (skewRight > 0) {
                context.lineTo(width, 0);
                context.lineTo(width-skewRight, height);
            } else if (skewRight < 0) {
                context.lineTo(width+skewRight, 0);
                context.lineTo(width, height);
            } else {
                context.lineTo(width, 0);
                context.lineTo(width, height);
            }

            context.lineTo(paddingLeft, height);

            context.closePath()
            context.fill()
        }

        Behavior on x
        {
            PropertyAnimation { duration: 100 }
        }

        Behavior on width
        {
            PropertyAnimation { duration: 100 }
        }

    }

    Text
    {
        id: buttonText
        x: paddingLeft
        y: paddingTop
        color: colors.buttonText

        font: buttonRoot.font

        text: ""
    }

    MouseArea
    {
        width: widthFull
        height: parent.height

        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true

        onEntered: 
        {
            buttonRoot.state = "hover"
            buttonBg.requestPaint()
        }

        onExited:
        {
            buttonRoot.state = "idle"
            buttonBg.requestPaint()
        }

        onClicked: buttonRoot.clicked()
    }
}