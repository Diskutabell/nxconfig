import QtQuick
import QtQuick.Layouts

Rectangle {
    id: action

    required property real sc
    required property string icon
    required property string label
    required property color accent
    signal triggered

    readonly property color fg: mouse.containsMouse ? accent : Qt.rgba(accent.r, accent.g, accent.b, 0.6)

    Layout.fillWidth: true
    Layout.preferredHeight: 48 * sc
    Layout.leftMargin: 10 * sc
    Layout.rightMargin: 10 * sc
    radius: 12 * sc
    color: mouse.containsMouse ? Qt.rgba(accent.r, accent.g, accent.b, 0.1) : "transparent"
    scale: mouse.pressed ? 0.95 : (mouse.containsMouse ? 1.02 : 1.0)

    Behavior on color { ColorAnimation { duration: 200 } }
    Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16 * action.sc
        anchors.rightMargin: 16 * action.sc

        Text {
            text: action.icon
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 18 * action.sc
            color: action.fg
        }
        Item { Layout.fillWidth: true }
        Text {
            text: action.label
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 15 * action.sc
            font.weight: Font.Medium
            color: action.fg
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: action.triggered()
    }
}
