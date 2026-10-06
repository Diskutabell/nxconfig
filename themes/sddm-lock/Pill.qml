import QtQuick

Rectangle {
    id: pill

    required property var colors
    required property real sc
    property string icon
    property string label
    property color accent: colors.mauve
    signal clicked

    readonly property bool hovered: mouse.containsMouse

    height: 48 * sc
    width: row.implicitWidth + 36 * sc
    radius: height / 2
    color: hovered ? Qt.rgba(colors.surface1.r, colors.surface1.g, colors.surface1.b, 0.6) : Qt.rgba(colors.surface0.r, colors.surface0.g, colors.surface0.b, 0.4)
    border.color: hovered ? accent : Qt.rgba(colors.text.r, colors.text.g, colors.text.b, 0.08)
    border.width: Math.max(1, sc)
    scale: hovered ? 1.05 : 1.0

    Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutExpo } }
    Behavior on color { ColorAnimation { duration: 200 } }
    Behavior on border.color { ColorAnimation { duration: 200 } }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 8 * pill.sc

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: pill.icon
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 18 * pill.sc
            color: pill.hovered ? pill.accent : pill.colors.overlay2
            Behavior on color { ColorAnimation { duration: 200 } }
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: pill.label
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 14 * pill.sc
            font.weight: Font.Black
            color: pill.colors.text
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: pill.clicked()
    }
}
