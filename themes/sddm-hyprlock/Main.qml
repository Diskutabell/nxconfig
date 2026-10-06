// hyprlock — SDDM greeter theme
//
// A 1:1 visual port of ~/.config/hypr/hyprlock.conf: blurred background,
// big mauve clock, date, username, and a rounded password field. Rendered on
// every screen, exactly like hyprlock's `monitor =` (empty = all monitors).

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15

Item {
    id: root

    // Size to the greeter window, NOT to Screen. SDDM opens one window per
    // output; Screen.* can report the whole virtual desktop on X11, which puts
    // the clock and field in the gap between two monitors instead of centred on
    // each one. Screen.* stays as a fallback for before the window exists.
    width: Window.width > 0 ? Window.width : Screen.width
    height: Window.height > 0 ? Window.height : Screen.height
    focus: true

    // ---- config with hyprlock defaults ------------------------------------
    readonly property string fontFamily: config.Font || "JetBrainsMono Nerd Font"
    readonly property color mauve:    config.Mauve    || "#cba6f7"
    readonly property color textCol:  config.Text     || "#cdd6f4"
    readonly property color lavender: config.Lavender || "#b4befe"
    readonly property color redCol:   config.Red      || "#f38ba8"
    readonly property color overlay0: config.Overlay0 || "#6c7086"
    readonly property color baseCol:  config.Base     || "#1e1e2e"

    readonly property int fieldW: parseInt(config.FieldWidth)  || 280
    readonly property int fieldH: parseInt(config.FieldHeight) || 50

    // hyprlock's `position = 0, N` is an offset upward from the screen centre.
    function offY(v, fallback) {
        var n = parseInt(v)
        return -(isNaN(n) ? fallback : n)
    }

    // ---- login state -------------------------------------------------------
    // "idle" | "checking" | "failed"
    property string loginState: "idle"

    property int userIndex: userModel.lastIndex >= 0 ? userModel.lastIndex : 0
    property string currentUser: userModel.count > 0
        ? userModel.data(userModel.index(userIndex, 0), Qt.UserRole + 1) || userModel.lastUser
        : userModel.lastUser

    property int sessionIndex: sessionModel.lastIndex

    function attemptLogin() {
        if (loginState === "checking")
            return
        loginState = "checking"
        sddm.login(root.currentUser, passwordField.text, root.sessionIndex)
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            root.loginState = "failed"
            passwordField.text = ""
            passwordField.forceActiveFocus()
        }
        function onLoginSucceeded() {
            root.loginState = "idle"
        }
    }

    // ---- background --------------------------------------------------------
    Rectangle {
        anchors.fill: parent
        color: config.FallbackColor || "#11111b"
    }

    Image {
        id: background
        anchors.fill: parent
        source: config.Background ? "file://" + config.Background : ""
        fillMode: Image.PreserveAspectCrop
        // Synchronous: the greeter has exactly one frame to get this right, and
        // an async decode pops the fallback colour in first.
        asynchronous: false
        cache: true
        smooth: true
        mipmap: true
        // The image is pre-blurred and pre-dimmed by the setup script; if that
        // has not run yet the fallback colour underneath shows through.
        visible: status === Image.Ready
    }

    MouseArea {
        anchors.fill: parent
        onClicked: passwordField.forceActiveFocus()
    }

    // ---- clock -------------------------------------------------------------
    Timer {
        id: clockTimer
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            var now = new Date()
            clockLabel.text = Qt.formatDateTime(now, "HH:mm")
            var d = Qt.formatDateTime(now, "dddd, dd MMMM")
            if (dateLabel.text !== d)
                dateLabel.text = d
        }
    }

    Text {
        id: clockLabel
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: root.offY(config.ClockOffset, 160)
        color: root.mauve
        font.family: root.fontFamily
        font.weight: Font.ExtraBold
        font.pixelSize: parseInt(config.ClockFontSize) || 90
    }

    // ---- date --------------------------------------------------------------
    Text {
        id: dateLabel
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: root.offY(config.DateOffset, 80)
        color: root.textCol
        font.family: root.fontFamily
        font.pixelSize: parseInt(config.DateFontSize) || 20
    }

    // ---- user --------------------------------------------------------------
    Text {
        id: userLabel
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: root.offY(config.UserOffset, 15)
        text: root.currentUser
        color: root.lavender
        font.family: root.fontFamily
        font.pixelSize: parseInt(config.UserFontSize) || 16

        // Only interactive when there is actually something to switch between.
        MouseArea {
            anchors.fill: parent
            anchors.margins: -8
            enabled: userModel.count > 1
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                root.userIndex = (root.userIndex + 1) % userModel.count
                passwordField.text = ""
                root.loginState = "idle"
                passwordField.forceActiveFocus()
            }
        }
    }

    // ---- password field ----------------------------------------------------
    Rectangle {
        id: inputField
        width: root.fieldW
        height: root.fieldH
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: root.offY(config.FieldOffset, -40)

        radius: parseInt(config.FieldRounding) || 12
        color: Qt.rgba(root.baseCol.r, root.baseCol.g, root.baseCol.b, 0.6)
        border.width: parseInt(config.FieldOutlineThickness) || 2
        border.color: root.loginState === "checking" ? root.lavender
                    : root.loginState === "failed"   ? root.redCol
                    : Qt.rgba(root.mauve.r, root.mauve.g, root.mauve.b, 0.9)

        Behavior on border.color { ColorAnimation { duration: 120 } }

        TextInput {
            id: passwordField
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            horizontalAlignment: TextInput.AlignHCenter
            verticalAlignment: TextInput.AlignVCenter

            echoMode: TextInput.Password
            passwordCharacter: "●"
            passwordMaskDelay: 0
            font.family: root.fontFamily
            // hyprlock's dots_size = 0.25 is a fraction of the field height; the
            // glyph box is roughly twice the ink, hence the x2 here.
            font.pixelSize: Math.round(root.fieldH * 0.25 * 1.8)
            // hyprlock's dots_spacing = 0.3
            font.letterSpacing: Math.round(root.fieldH * 0.25 * 0.3)
            color: root.textCol
            selectionColor: root.mauve
            selectedTextColor: root.baseCol
            clip: true
            focus: true
            enabled: root.loginState !== "checking"

            onTextChanged: if (root.loginState === "failed" && text.length > 0) root.loginState = "idle"
            onAccepted: root.attemptLogin()

            Keys.onPressed: function (event) {
                if (event.key === Qt.Key_Escape) {
                    text = ""
                    root.loginState = "idle"
                    event.accepted = true
                }
            }
        }

        // placeholder / fail text, hyprlock renders these inside the field
        Text {
            anchors.centerIn: parent
            visible: passwordField.text.length === 0
            text: root.loginState === "failed" ? (config.FailText || "Wrong")
                                               : (config.PlaceholderText || "Enter Password")
            color: root.loginState === "failed" ? root.redCol : root.overlay0
            font.family: root.fontFamily
            font.pixelSize: 14
            }
    }

    // ---- session picker (bottom left) --------------------------------------
    Text {
        id: sessionLabel
        visible: sessionModel.count > 1
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: 28
        text: sessionModel.data(sessionModel.index(root.sessionIndex, 0), Qt.UserRole + 4) || ""
        color: root.textCol
        opacity: sessionArea.containsMouse ? 1.0 : 0.45
        font.family: root.fontFamily
        font.pixelSize: 14
        Behavior on opacity { NumberAnimation { duration: 120 } }

        MouseArea {
            id: sessionArea
            anchors.fill: parent
            anchors.margins: -8
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                root.sessionIndex = (root.sessionIndex + 1) % sessionModel.count
                passwordField.forceActiveFocus()
            }
        }
    }

    // ---- power controls (bottom right) -------------------------------------
    Row {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 24
        spacing: 8

        Repeater {
            model: [
                { glyph: "⏻", action: "poweroff", enabled: sddm.canPowerOff },
                { glyph: "↻", action: "reboot",   enabled: sddm.canReboot },
                { glyph: "☽", action: "suspend",  enabled: sddm.canSuspend }
            ]

            delegate: Rectangle {
                width: 40
                height: 40
                radius: 12
                visible: modelData.enabled
                color: powerArea.containsMouse
                    ? Qt.rgba(root.mauve.r, root.mauve.g, root.mauve.b, 0.20)
                    : Qt.rgba(root.baseCol.r, root.baseCol.g, root.baseCol.b, 0.45)
                border.width: 1
                border.color: Qt.rgba(root.mauve.r, root.mauve.g, root.mauve.b,
                                      powerArea.containsMouse ? 0.9 : 0.35)
                Behavior on color { ColorAnimation { duration: 120 } }

                Text {
                    anchors.centerIn: parent
                    text: modelData.glyph
                    color: powerArea.containsMouse ? root.mauve : root.textCol
                    font.family: root.fontFamily
                    font.pixelSize: 18
                            }

                MouseArea {
                    id: powerArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (modelData.action === "poweroff") sddm.powerOff()
                        else if (modelData.action === "reboot") sddm.reboot()
                        else sddm.suspend()
                    }
                }
            }
        }
    }

    Component.onCompleted: passwordField.forceActiveFocus()
}
