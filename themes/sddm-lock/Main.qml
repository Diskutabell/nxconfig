import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Window

Item {
    id: root

    width: Window.width > 0 ? Window.width : Screen.width
    height: Window.height > 0 ? Window.height : Screen.height

    readonly property string stateDir: config.StateDir || "/var/lib/sddm-lock"
    readonly property string font: "JetBrainsMono Nerd Font"

    readonly property real sc: {
        const r = Math.min(width / 1920, 1)
        return r < 1 ? Math.max(0.35, Math.pow(r, 0.85)) : 1
    }

    Colors { id: c }
    Component.onCompleted: c.load(stateDir + "/colors.json")

    property int userIndex: Math.max(userModel.lastIndex, 0)
    readonly property string currentUser:
        userModel.data(userModel.index(userIndex, 0), Qt.UserRole + 1) || userModel.lastUser
    property int sessionIndex: sessionModel.lastIndex
    readonly property string sessionName:
        sessionModel.data(sessionModel.index(sessionIndex, 0), Qt.UserRole + 4) || ""

    property bool failed: false
    property bool authenticating: false
    property string statusText: "Locked"
    property bool inputActive: false
    property bool powerMenuOpen: false
    property bool playingIntro: true
    property real introState: 0.0
    property bool hidePassword: false
    property int revealDuration: 300

    readonly property color stateColor: failed ? c.red : authenticating ? c.peach : c.mauve

    function login() {
        if (inputField.text.length === 0 || authenticating)
            return
        authenticating = true
        failed = false
        statusText = "Authenticating..."
        sddm.login(currentUser, inputField.text, sessionIndex)
        inputField.text = ""
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            root.authenticating = false
            root.failed = true
            root.statusText = "Access Denied"
        }
    }

    property real orbit: 0
    NumberAnimation on orbit {
        from: 0; to: Math.PI * 2; duration: 90000; loops: Animation.Infinite
    }

    Timer {
        interval: 15000
        running: root.inputActive && inputField.text.length === 0
        onTriggered: root.inputActive = false
    }

    Rectangle {
        anchors.fill: parent
        color: c.base
    }

    Image {
        anchors.fill: parent
        source: "file://" + root.stateDir + "/background.png"
        fillMode: Image.PreserveAspectCrop
        cache: false
    }

    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: 0.25
    }

    Item {
        anchors.fill: parent

        Rectangle {
            width: parent.width * 0.8; height: width; radius: width / 2
            x: parent.width / 2 - width / 2 + Math.cos(root.orbit * 2) * 200 * root.sc
            y: parent.height / 2 - height / 2 + Math.sin(root.orbit * 2) * 150 * root.sc
            scale: 1.0 + Math.sin(root.orbit * 6) * 0.05
            opacity: root.inputActive ? 0.04 : 0.08
            color: c.mauve
            Behavior on opacity { NumberAnimation { duration: 600 } }
        }

        Rectangle {
            width: parent.width * 0.9; height: width; radius: width / 2
            x: parent.width / 2 - width / 2 - Math.sin(root.orbit * 1.5) * 200 * root.sc
            y: parent.height / 2 - height / 2 - Math.cos(root.orbit * 1.5) * 150 * root.sc
            scale: 1.0 + Math.cos(root.orbit * 5) * 0.05
            opacity: root.inputActive ? 0.03 : 0.06
            color: c.blue
            Behavior on opacity { NumberAnimation { duration: 600 } }
        }

        Repeater {
            model: 4
            Rectangle {
                required property int index
                anchors.centerIn: parent
                anchors.verticalCenterOffset: -40 * root.sc
                width: (400 + index * 220) * root.sc
                height: width
                radius: width / 2
                color: "transparent"
                border.color: root.failed ? c.red : c.text
                border.width: Math.max(1, root.sc)
                opacity: root.introState * (root.failed ? 0.1 - index * 0.02
                                          : root.inputActive ? 0.02 - index * 0.005
                                          : 0.04 - index * 0.01)
                scale: 1.1 - 0.1 * root.introState
                Behavior on border.color { ColorAnimation { duration: 600; easing.type: Easing.OutExpo } }
                Behavior on opacity { NumberAnimation { duration: 600; easing.type: Easing.OutExpo } }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: !root.playingIntro
        onClicked: {
            root.powerMenuOpen = false
            root.inputActive = true
            inputField.forceActiveFocus()
        }
    }

    Item {
        anchors.fill: parent
        opacity: root.introState
        transform: Translate { y: 30 * root.sc * (1.0 - root.introState) }

        ColumnLayout {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: (root.inputActive ? -120 : -40) * root.sc
            spacing: -10 * root.sc
            opacity: root.inputActive ? 0.0 : 1.0
            scale: root.inputActive ? 0.9 : 1.0
            visible: opacity > 0.01

            Behavior on anchors.verticalCenterOffset { NumberAnimation { duration: 600; easing.type: Easing.OutExpo } }
            Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
            Behavior on scale { NumberAnimation { duration: 500; easing.type: Easing.OutBack } }

            Row {
                Layout.alignment: Qt.AlignHCenter
                Text { id: hours; font.family: root.font; font.pixelSize: 140 * root.sc; font.weight: Font.Bold; color: c.text }
                Text { text: ":"; font.family: root.font; font.pixelSize: 140 * root.sc; font.weight: Font.Bold; color: c.text; opacity: 0.5 }
                Text { id: minutes; font.family: root.font; font.pixelSize: 140 * root.sc; font.weight: Font.Bold; color: c.text }
            }

            Text {
                id: date
                Layout.alignment: Qt.AlignHCenter
                font.family: root.font
                font.pixelSize: 22 * root.sc
                font.weight: Font.Bold
                color: c.text
            }

            Timer {
                interval: 1000; running: true; repeat: true; triggeredOnStart: true
                onTriggered: {
                    const now = new Date()
                    hours.text = Qt.formatDateTime(now, "hh")
                    minutes.text = Qt.formatDateTime(now, "mm")
                    date.text = Qt.formatDateTime(now, "dddd, MMMM dd")
                }
            }
        }

        RowLayout {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: (root.inputActive ? -40 : 40) * root.sc
            spacing: 32 * root.sc
            opacity: root.inputActive ? 1.0 : 0.0
            scale: root.inputActive ? 1.0 : 0.9
            visible: opacity > 0.01

            Behavior on anchors.verticalCenterOffset { NumberAnimation { duration: 600; easing.type: Easing.OutExpo } }
            Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
            Behavior on scale { NumberAnimation { duration: 500; easing.type: Easing.OutBack } }

            Item {
                Layout.alignment: Qt.AlignVCenter
                width: 170 * root.sc
                height: width

                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: Qt.rgba(c.surface0.r, c.surface0.g, c.surface0.b, 0.5)
                    visible: face.status !== Image.Ready

                    Text {
                        anchors.centerIn: parent
                        text: "󰄽"
                        font.family: root.font
                        font.pixelSize: 64 * root.sc
                        color: c.subtext0
                    }
                }

                Image {
                    id: face
                    anchors.fill: parent
                    source: "file://" + root.stateDir + "/face.png"
                    fillMode: Image.PreserveAspectCrop
                    visible: false
                }

                Rectangle {
                    id: faceMask
                    anchors.fill: parent
                    radius: width / 2
                    visible: false
                    layer.enabled: true
                }

                MultiEffect {
                    anchors.fill: parent
                    source: face
                    maskEnabled: true
                    maskSource: faceMask
                    visible: face.status === Image.Ready
                }

                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: "transparent"
                    border.color: root.failed || root.authenticating ? root.stateColor
                                                                     : Qt.rgba(c.text.r, c.text.g, c.text.b, 0.5)
                    border.width: Math.max(1, 3 * root.sc)
                    Behavior on border.color { ColorAnimation { duration: 300 } }
                }
            }

            ColumnLayout {
                Layout.alignment: Qt.AlignVCenter
                spacing: 16 * root.sc

                Text {
                    text: root.currentUser
                    font.family: root.font
                    font.pixelSize: 28 * root.sc
                    font.weight: Font.Bold
                    color: c.text

                    MouseArea {
                        anchors.fill: parent
                        enabled: userModel.count > 1
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.userIndex = (root.userIndex + 1) % userModel.count
                    }
                }

                RowLayout {
                    spacing: 12 * root.sc

                    Rectangle {
                        width: 36 * root.sc
                        height: width
                        radius: width / 2
                        color: Qt.rgba(root.stateColor.r, root.stateColor.g, root.stateColor.b,
                                       root.failed || root.authenticating ? 0.2 : 0.15)
                        border.color: root.stateColor
                        border.width: Math.max(1, root.sc)
                        Behavior on color { ColorAnimation { duration: 300 } }

                        Text {
                            anchors.centerIn: parent
                            text: root.authenticating ? "󰌿" : "󰌾"
                            font.family: root.font
                            font.pixelSize: 18 * root.sc
                            color: root.stateColor
                        }
                    }

                    Text {
                        text: root.statusText.toUpperCase()
                        font.family: root.font
                        font.pixelSize: 14 * root.sc
                        font.weight: Font.Medium
                        font.letterSpacing: 2.0
                        color: root.failed || root.authenticating ? root.stateColor : c.text
                        Behavior on color { ColorAnimation { duration: 300 } }
                    }
                }

                Rectangle {
                    id: pinPill
                    width: 280 * root.sc
                    height: 60 * root.sc
                    radius: height / 2
                    clip: true
                    color: root.failed ? Qt.rgba(c.red.r, c.red.g, c.red.b, 0.1)
                                       : Qt.rgba(c.surface0.r, c.surface0.g, c.surface0.b, 0.5)
                    border.width: Math.max(1, 2 * root.sc)
                    border.color: root.failed || root.authenticating ? root.stateColor
                                : inputField.text.length > 0 ? c.text
                                : Qt.rgba(c.text.r, c.text.g, c.text.b, 0.08)
                    scale: root.failed ? 1.05 : root.authenticating ? 0.98 : 1.0

                    Behavior on color { ColorAnimation { duration: 250; easing.type: Easing.OutExpo } }
                    Behavior on border.color { ColorAnimation { duration: 250; easing.type: Easing.OutExpo } }
                    Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }

                    transform: Translate { id: shake }
                    SequentialAnimation {
                        id: shakeAnim
                        NumberAnimation { target: shake; property: "x"; to: -8 * root.sc; duration: 120; easing.type: Easing.InOutSine }
                        NumberAnimation { target: shake; property: "x"; to: 8 * root.sc; duration: 120; easing.type: Easing.InOutSine }
                        NumberAnimation { target: shake; property: "x"; to: 0; duration: 120; easing.type: Easing.InOutSine }
                    }
                    Connections {
                        target: root
                        function onFailedChanged() { if (root.failed) shakeAnim.restart() }
                    }

                    TextInput {
                        id: inputField
                        anchors.fill: parent
                        opacity: 0
                        echoMode: TextInput.Password
                        enabled: !root.playingIntro
                        focus: true

                        property string shown: ""

                        onActiveFocusChanged: if (!activeFocus && !root.powerMenuOpen) forceActiveFocus()
                        onAccepted: root.login()

                        Keys.onPressed: event => {
                            if (event.key === Qt.Key_Escape) {
                                root.inputActive = false
                                text = ""
                                event.accepted = true
                            } else {
                                root.inputActive = true
                            }
                        }

                        onTextChanged: {
                            let same = 0
                            while (same < text.length && same < shown.length && text[same] === shown[same])
                                same++
                            while (dots.count > same)
                                dots.remove(dots.count - 1)
                            for (let i = same; i < text.length; i++)
                                dots.append({ ch: text[i], isDot: root.hidePassword })
                            shown = text

                            if (text.length > 0) {
                                root.inputActive = true
                                root.failed = false
                                root.statusText = "Enter PIN"
                            } else if (!root.failed && !root.authenticating) {
                                root.statusText = "Locked"
                            }
                        }
                    }

                    ListModel { id: dots }

                    Item {
                        anchors.fill: parent
                        anchors.leftMargin: 20 * root.sc
                        anchors.rightMargin: 20 * root.sc
                        clip: true

                        Row {
                            anchors.verticalCenter: parent.verticalCenter
                            x: width > parent.width ? parent.width - width : (parent.width - width) / 2
                            spacing: 4 * root.sc
                            Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

                            Repeater {
                                model: dots
                                delegate: Text {
                                    id: glyph
                                    required property int index
                                    required property string ch
                                    required property bool isDot

                                    text: isDot ? "•" : ch
                                    height: pinPill.height
                                    verticalAlignment: Text.AlignVCenter
                                    font.family: root.font
                                    font.pixelSize: (isDot ? 32 : 24) * root.sc
                                    font.weight: Font.Bold
                                    color: root.failed || root.authenticating ? root.stateColor : c.text

                                    NumberAnimation on opacity { from: 0; to: 1; duration: 150 }

                                    Timer {
                                        interval: root.revealDuration
                                        running: !glyph.isDot
                                        onTriggered: dots.setProperty(glyph.index, "isDot", true)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Row {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 40 * root.sc
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 16 * root.sc
        opacity: root.introState
        transform: Translate { y: 20 * root.sc * (1.0 - root.introState) }

        Pill {
            colors: c
            sc: root.sc
            icon: "󰌌"
            label: keyboard.layouts.length > 0
                   ? keyboard.layouts[keyboard.currentLayout].shortName.toUpperCase() : ""
            visible: label !== ""
            onClicked: keyboard.currentLayout = (keyboard.currentLayout + 1) % keyboard.layouts.length
        }

        Pill {
            colors: c
            sc: root.sc
            icon: "󰍹"
            label: root.sessionName
            accent: c.blue
            visible: sessionModel.count > 1
            onClicked: root.sessionIndex = (root.sessionIndex + 1) % sessionModel.count
        }
    }

    Rectangle {
        anchors.bottom: powerBtn.top
        anchors.right: parent.right
        anchors.bottomMargin: 15 * root.sc
        anchors.rightMargin: 40 * root.sc
        width: 280 * root.sc
        height: root.powerMenuOpen ? menu.implicitHeight + 20 * root.sc : 0
        radius: 18 * root.sc
        clip: true
        opacity: root.powerMenuOpen ? 1 : 0
        color: Qt.rgba(c.surface0.r, c.surface0.g, c.surface0.b, 0.95)
        border.color: Qt.rgba(c.mauve.r, c.mauve.g, c.mauve.b, 0.25)
        border.width: Math.max(1, root.sc)

        Behavior on height { NumberAnimation { duration: 350; easing.type: Easing.OutExpo } }
        Behavior on opacity { NumberAnimation { duration: 250 } }

        ColumnLayout {
            id: menu
            anchors.top: parent.top
            anchors.topMargin: 10 * root.sc
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 6 * root.sc

            component Heading: Text {
                font.family: root.font
                font.weight: Font.Black
                font.pixelSize: 12 * root.sc
                font.letterSpacing: 1.5
                color: c.mauve
                Layout.leftMargin: 18 * root.sc
                Layout.topMargin: 4 * root.sc
                Layout.bottomMargin: 4 * root.sc
            }

            Heading { text: "SETTINGS" }

            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 18 * root.sc
                Layout.rightMargin: 18 * root.sc
                Layout.topMargin: 4 * root.sc

                Text {
                    Layout.fillWidth: true
                    text: "Hide password"
                    font.family: root.font
                    font.pixelSize: 14 * root.sc
                    font.weight: Font.Medium
                    color: c.text
                }

                Rectangle {
                    width: 40 * root.sc
                    height: 22 * root.sc
                    radius: height / 2
                    color: root.hidePassword ? c.mauve : c.surface2
                    Behavior on color { ColorAnimation { duration: 250 } }

                    Rectangle {
                        width: height
                        height: 18 * root.sc
                        radius: height / 2
                        anchors.verticalCenter: parent.verticalCenter
                        x: root.hidePassword ? parent.width - width - 2 * root.sc : 2 * root.sc
                        color: c.base
                        Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            root.hidePassword = !root.hidePassword
                            if (root.hidePassword)
                                for (let i = 0; i < dots.count; i++)
                                    dots.setProperty(i, "isDot", true)
                        }
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 18 * root.sc
                Layout.rightMargin: 18 * root.sc
                Layout.topMargin: 8 * root.sc
                Layout.bottomMargin: 8 * root.sc
                spacing: 8 * root.sc
                opacity: root.hidePassword ? 0.3 : 1.0
                Behavior on opacity { NumberAnimation { duration: 200 } }

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        Layout.fillWidth: true
                        text: "Reveal delay"
                        font.family: root.font
                        font.pixelSize: 14 * root.sc
                        font.weight: Font.Medium
                        color: c.blue
                    }
                    Text {
                        text: root.revealDuration >= 1000 ? (root.revealDuration / 1000).toFixed(1) + " s"
                                                          : root.revealDuration + " ms"
                        font.family: root.font
                        font.pixelSize: 13 * root.sc
                        font.weight: Font.Bold
                        color: c.peach
                    }
                }

                Item {
                    id: slider
                    Layout.fillWidth: true
                    Layout.preferredHeight: 28 * root.sc
                    readonly property real frac: (root.revealDuration - 100) / 2900

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width
                        height: 8 * root.sc
                        radius: height / 2
                        color: c.surface2
                        Rectangle {
                            width: slider.frac * parent.width
                            height: parent.height
                            radius: height / 2
                            color: c.mauve
                        }
                    }

                    Rectangle {
                        width: 20 * root.sc
                        height: width
                        radius: width / 2
                        anchors.verticalCenter: parent.verticalCenter
                        x: Math.max(0, Math.min(slider.frac * parent.width - width / 2, parent.width - width))
                        color: c.peach
                        border.color: c.crust
                        border.width: Math.max(1, 2 * root.sc)
                        scale: sliderMouse.pressed ? 1.3 : sliderMouse.containsMouse ? 1.15 : 1.0
                        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                    }

                    MouseArea {
                        id: sliderMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: !root.hidePassword
                        preventStealing: true

                        function set(mx) {
                            let ms = Math.round(100 + Math.max(0, Math.min(1, mx / width)) * 2900)
                            const rest = ms % 100
                            if (rest < 10) ms -= rest
                            else if (rest > 90) ms += 100 - rest
                            root.revealDuration = ms
                        }
                        onPressed: mouse => set(mouse.x)
                        onPositionChanged: mouse => { if (pressed) set(mouse.x) }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Math.max(1, root.sc)
                Layout.leftMargin: 18 * root.sc
                Layout.rightMargin: 18 * root.sc
                Layout.topMargin: 4 * root.sc
                Layout.bottomMargin: 4 * root.sc
                color: Qt.rgba(c.mauve.r, c.mauve.g, c.mauve.b, 0.2)
            }

            Heading { text: "SYSTEM" }

            MenuAction {
                sc: root.sc; icon: "󰜉"; label: "Reboot"; accent: c.blue
                visible: sddm.canReboot
                onTriggered: sddm.reboot()
            }
            MenuAction {
                sc: root.sc; icon: "󰒲"; label: "Suspend"; accent: c.mauve
                visible: sddm.canSuspend
                onTriggered: { root.powerMenuOpen = false; sddm.suspend() }
            }
            MenuAction {
                sc: root.sc; icon: "󰐥"; label: "Power Off"; accent: c.red
                visible: sddm.canPowerOff
                Layout.bottomMargin: 8 * root.sc
                onTriggered: sddm.powerOff()
            }
        }
    }

    Rectangle {
        id: powerBtn
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 40 * root.sc
        width: 52 * root.sc
        height: width
        radius: width / 2
        color: root.powerMenuOpen ? c.surface2
             : powerMouse.containsMouse ? Qt.rgba(c.surface1.r, c.surface1.g, c.surface1.b, 0.8)
             : Qt.rgba(c.surface0.r, c.surface0.g, c.surface0.b, 0.4)
        border.color: root.powerMenuOpen ? c.text : Qt.rgba(c.text.r, c.text.g, c.text.b, 0.15)
        border.width: Math.max(1, root.sc)
        opacity: root.introState
        scale: powerMouse.pressed ? 0.9 : powerMouse.containsMouse ? 1.08 : 1.0
        transform: Translate { y: 20 * root.sc * (1.0 - root.introState) }

        Behavior on color { ColorAnimation { duration: 200 } }
        Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }

        Text {
            anchors.centerIn: parent
            text: "󰐥"
            font.family: root.font
            font.pixelSize: 22 * root.sc
            color: root.powerMenuOpen ? c.red : powerMouse.containsMouse ? c.text : c.subtext0
        }

        MouseArea {
            id: powerMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            enabled: !root.playingIntro
            onClicked: {
                root.powerMenuOpen = !root.powerMenuOpen
                if (!root.powerMenuOpen)
                    inputField.forceActiveFocus()
            }
        }
    }

    Item {
        id: intro
        anchors.fill: parent
        z: 999
        visible: opacity > 0

        component Ring: Rectangle {
            anchors.centerIn: parent
            height: width
            radius: width / 2
            color: "transparent"
            border.width: Math.max(1, root.sc)
            opacity: 0
        }
        Ring { id: ring3; width: 360 * root.sc; border.color: c.mauve }
        Ring { id: ring2; width: 300 * root.sc; border.color: c.text }
        Ring { id: ring1; width: 240 * root.sc; border.color: c.text; border.width: Math.max(1, 2 * root.sc) }

        Item {
            id: orb
            width: 170 * root.sc
            height: width
            anchors.centerIn: parent
            scale: 0
            opacity: 0

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: Qt.rgba(c.surface0.r, c.surface0.g, c.surface0.b, 0.9)
                border.color: c.text
                border.width: Math.max(1, 2 * root.sc)
            }
            Text { id: openIcon; anchors.centerIn: parent; text: "󰌿"; font.family: root.font; font.pixelSize: 64 * root.sc; color: c.text }
            Text { id: shutIcon; anchors.centerIn: parent; text: "󰌾"; font.family: root.font; font.pixelSize: 64 * root.sc; color: c.text; opacity: 0; scale: 1.6 }
        }

        SequentialAnimation {
            running: true

            ParallelAnimation {
                NumberAnimation { target: orb; property: "scale"; from: 0; to: 1; duration: 300; easing.type: Easing.OutCubic }
                NumberAnimation { target: orb; property: "opacity"; from: 0; to: 1; duration: 200; easing.type: Easing.OutCubic }
                NumberAnimation { target: ring1; property: "scale"; from: 0.8; to: 1.25; duration: 250; easing.type: Easing.OutCubic }
                NumberAnimation { target: ring1; property: "opacity"; from: 0.6; to: 0; duration: 250; easing.type: Easing.OutCubic }
                NumberAnimation { target: ring2; property: "scale"; from: 0.8; to: 1.4; duration: 300; easing.type: Easing.OutCubic }
                NumberAnimation { target: ring2; property: "opacity"; from: 0.4; to: 0; duration: 300; easing.type: Easing.OutCubic }
                NumberAnimation { target: ring3; property: "scale"; from: 0.5; to: 1.5; duration: 350; easing.type: Easing.OutCubic }
                NumberAnimation { target: ring3; property: "opacity"; from: 0.3; to: 0; duration: 350; easing.type: Easing.OutCubic }

                SequentialAnimation {
                    PauseAnimation { duration: 300 }
                    ParallelAnimation {
                        NumberAnimation { target: openIcon; property: "scale"; to: 0.5; duration: 100; easing.type: Easing.InCubic }
                        NumberAnimation { target: openIcon; property: "opacity"; to: 0; duration: 50 }
                        NumberAnimation { target: shutIcon; property: "scale"; to: 1; duration: 200; easing.type: Easing.OutBack }
                        NumberAnimation { target: shutIcon; property: "opacity"; to: 1; duration: 100 }
                        SequentialAnimation {
                            NumberAnimation { target: orb; property: "anchors.verticalCenterOffset"; to: 3 * root.sc; duration: 40; easing.type: Easing.OutQuad }
                            NumberAnimation { target: orb; property: "anchors.verticalCenterOffset"; to: 0; duration: 120; easing.type: Easing.OutBack }
                        }
                    }
                }
            }

            PauseAnimation { duration: 50 }

            ParallelAnimation {
                NumberAnimation { target: orb; property: "scale"; to: 1.8; duration: 100; easing.type: Easing.InCubic }
                NumberAnimation { target: intro; property: "opacity"; to: 0; duration: 100; easing.type: Easing.InCubic }
            }
            NumberAnimation { target: root; property: "introState"; from: 0; to: 1; duration: 100; easing.type: Easing.OutCubic }
            PropertyAction { target: root; property: "playingIntro"; value: false }
            ScriptAction { script: inputField.forceActiveFocus() }
        }
    }
}
