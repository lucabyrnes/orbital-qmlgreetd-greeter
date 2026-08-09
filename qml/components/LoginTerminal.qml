import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Effects
import QtQuick.Shapes

Item {
    id: root

    property real u: 10
    property var auth
    property var users
    property var sessions
    property string defaultSession: ""
    property color cyan: "#22B8CF"
    property color focusColor: "#35D5E8"
    property color magenta: "#D85A9F"
    property color green: "#55C985"
    property color panelColor: "#F2071019"
    property color panelWashColor: "#0B1621"
    property color borderColor: "#263746"
    property color fieldColor: "#080F17"
    property color focusFieldColor: "#09141D"
    property color fieldBorderColor: "#1C2A36"
    property color dividerColor: "#182633"
    property color iconColor: "#718596"
    property color textColor: "#DCE6EC"
    property color mutedText: "#7F92A3"
    property string titleFontFamily: "Eurostile"
    property string bodyFontFamily: "Inter"
    readonly property real contentU: Math.min(root.u, root.height / 54.0)
    property color failureColor: "#D85A6A"
    property string authenticationState: "idle"
    property string authenticationMessage: ""
    property bool restartingForUser: false
    property bool waitingForPrompt: false
    property string pendingSessionCommand: ""
    function selectInitialUser() {
        if (!root.users || accountSelection.count <= 0) {
            accountSelection.currentIndex = -1
            return
        }

        accountSelection.currentIndex = 0
        root.selectDefaultSession()
    }

    function selectDefaultSession() {
        if (!root.sessions || sessionSelection.count <= 0)
            return

        let selected = 0
        if (root.defaultSession !== "") {
            for (let index = 0; index < root.sessions.rowCount(); ++index) {
                const name = root.sessions.data(root.sessions.index(index, 0), 257)
                if (name === root.defaultSession || name.indexOf(root.defaultSession) !== -1) {
                    selected = index
                    break
                }
            }
        }
        sessionSelection.currentIndex = selected
    }

    function selectedUserName() {
        if (accountSelection.currentValue !== undefined
                && accountSelection.currentValue !== null
                && String(accountSelection.currentValue).length > 0) {
            return String(accountSelection.currentValue)
        }

        return accountSelection.currentText
    }

    function beginLogin() {
        if (!root.auth || root.auth.processing || root.auth.currentPrompt !== ""
                || root.selectedUserName() === "") {
            return
        }

        root.waitingForPrompt = true
        root.authenticationState = "idle"
        root.authenticationMessage = "CONNECTING TO AUTHENTICATION SERVICE..."
        root.auth.login(root.selectedUserName())
    }

    function switchUser() {
        if (!root.auth || root.auth.processing || root.authenticationState === "success")
            return

        if (root.auth.currentPrompt === "") {
            root.beginLogin()
            return
        }

        root.restartingForUser = true
        root.authenticationState = "pending"
        root.auth.cancel()
    }

    function submitLogin() {
        if (!root.auth || root.auth.processing || root.authenticationState === "success") {
            return
        }

        if (root.auth.currentPrompt === "") {
            root.beginLogin()
            return
        }

        root.authenticationState = "pending"
        root.authenticationMessage = "AUTHENTICATING..."
        root.auth.respond(passwordField.text)
    }

    function showAuthenticationResult(succeeded) {
        root.authenticationState = succeeded ? "success" : "failure"
        root.authenticationMessage = succeeded ? "ACCESS GRANTED" : "INVALID PASSWORD"

        const resultColor = succeeded ? root.green : root.failureColor
        accountSelection.validationColor = resultColor
        accountSelection.validationStrength = 1
        passwordField.validationColor = resultColor
        passwordField.validationStrength = 1

        if (!succeeded) {
            passwordField.clear()
            feedbackResetTimer.restart()
        }
    }

    Component.onCompleted: {
        root.selectInitialUser()
        Qt.callLater(root.beginLogin)
    }

    Connections {
        target: root.users
        ignoreUnknownSignals: true

        function onRowsInserted() {
            if (accountSelection.currentIndex < 0)
                root.selectInitialUser()
        }

        function onModelReset() { root.selectInitialUser() }
    }

    Connections {
        target: root.sessions
        ignoreUnknownSignals: true

        function onRowsInserted() { root.selectDefaultSession() }
        function onModelReset() { root.selectDefaultSession() }
    }

    Connections {
        target: root.auth
        ignoreUnknownSignals: true

        function onPromptChanged() {
            if (root.auth.currentPrompt !== "") {
                root.waitingForPrompt = false
                root.authenticationState = "idle"
                root.authenticationMessage = root.auth.currentPrompt
                passwordField.clear()
                passwordField.forceActiveFocus()
            } else if (root.restartingForUser) {
                root.restartingForUser = false
                Qt.callLater(root.beginLogin)
            }
        }

        function onProcessingChanged() {
            if (root.auth.processing && !root.waitingForPrompt
                    && root.authenticationState !== "success")
                root.authenticationState = "pending"
        }

        function onLoginSucceeded() {
            root.showAuthenticationResult(true)
            const command = root.sessions.execCommand(sessionSelection.currentIndex)
            if (command === "") {
                root.auth.error = "The selected session has no launch command."
                return
            }
            root.pendingSessionCommand = command
            sessionStartTimer.start()
        }

        function onErrorChanged() {
            if (root.auth.error === "")
                return
            root.showAuthenticationResult(false)
        }
    }

    Timer {
        id: sessionStartTimer
        interval: 1000
        repeat: false
        onTriggered: {
            if (root.pendingSessionCommand !== "")
                root.auth.startSession(root.pendingSessionCommand)
        }
    }

    Timer {
        id: feedbackResetTimer
        interval: 1850
        repeat: false
        onTriggered: {
            accountSelection.validationStrength = 0
            passwordField.validationStrength = 0
            root.authenticationState = "idle"
            root.authenticationMessage = ""
            if (root.auth && root.auth.currentPrompt !== "")
                passwordField.forceActiveFocus()
            else
                root.beginLogin()
        }
    }

    InstrumentPane {
        anchors.fill: parent
        cornerRadius: root.u * 1.3
        inset: root.contentU * 0.8
        contentMargin: 0
        surfaceTop: "#F316222C"
        surfaceMiddle: "#F009131C"
        surfaceBottom: "#F2050D15"
        outlineColor: "#52667884"

        ColumnLayout {
            anchors.fill: parent
            anchors.leftMargin: root.contentU * 3.0
            anchors.rightMargin: root.contentU * 3.0
            anchors.topMargin: root.contentU * 1.65
            anchors.bottomMargin: root.contentU * 1.6
            spacing: root.contentU * 0.9

        Item {
            id: dishBadge
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: root.contentU * 10.0
            Layout.preferredHeight: root.contentU * 10.0

            // Minimal cyan halo behind the dish.
            Rectangle {
                id: dishPlate
                anchors.centerIn: parent
                width: parent.width * 1.1
                height: width
                radius: width / 2
                color: "transparent"
                border.width: Math.max(1, root.contentU * 0.10)
                border.color: Qt.rgba(root.cyan.r, root.cyan.g, root.cyan.b, 0.7)

                Shape {
                    anchors.fill: parent

                    ShapePath {
                        strokeWidth: 0
                        fillGradient: LinearGradient {
                            x1: dishPlate.width
                            y1: 0
                            x2: 0
                            y2: dishPlate.height
                            GradientStop {
                                position: 0.0
                                color: Qt.rgba(root.cyan.r, root.cyan.g, root.cyan.b, 0.16)
                            }
                            GradientStop {
                                position: 0.52
                                color: Qt.rgba(0.035, 0.090, 0.13, 0.38)
                            }
                            GradientStop {
                                position: 1.0
                                color: Qt.rgba(0.012, 0.035, 0.055, 0.62)
                            }
                        }

                        PathAngleArc {
                            centerX: dishPlate.width / 2
                            centerY: dishPlate.height / 2
                            radiusX: dishPlate.width / 2
                            radiusY: dishPlate.height / 2
                            startAngle: 0
                            sweepAngle: 360
                        }
                    }
                }

                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowColor: root.cyan
                    shadowOpacity: 0.22
                    shadowBlur: 0.75
                    shadowScale: 1.10
                }
            }

            DishGlyph {
                anchors.centerIn: parent
                width: parent.width * 0.66
                height: parent.height * 0.76
                primaryColor: root.cyan
                secondaryColor: root.textColor
            }
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "GROUND STATION ACCESS"
            color: root.textColor
            font.family: root.titleFontFamily
            font.pixelSize: root.contentU * 2.325
            font.letterSpacing: root.contentU * 0.13
            font.weight: Font.Medium
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "Local session authentication"
            color: root.mutedText
            font.family: root.bodyFontFamily
            font.pixelSize: root.contentU * 1.35
            font.letterSpacing: 0
            Layout.bottomMargin: root.contentU * 0.05
        }

        TerminalDropDown {
            id: accountSelection
            Layout.fillWidth: true
            u: root.contentU
            model: root.users || []
            textRole: "realName"
            valueRole: "username"
            iconText: "\ued35"
            accent: root.iconColor
            fieldColor: root.fieldColor
            focusFieldColor: root.focusFieldColor
            borderColor: root.fieldBorderColor
            dividerColor: root.dividerColor
            focusBorderColor: root.focusColor
            textColor: root.textColor
            mutedText: root.mutedText
            bodyFontFamily: root.bodyFontFamily
            enabled: root.authenticationState !== "pending" && root.authenticationState !== "success"
            onAccepted: passwordField.forceActiveFocus()
            onSelectionActivated: root.switchUser()
        }

        TerminalField {
            id: passwordField
            Layout.fillWidth: true
            u: root.contentU
            placeholderText: root.auth && root.auth.currentPrompt !== "" ? root.auth.currentPrompt : "Password"
            password: !root.auth || root.auth.isSecret
            iconText: "\ue672"
            accent: root.iconColor
            fieldColor: root.fieldColor
            focusFieldColor: root.focusFieldColor
            borderColor: root.fieldBorderColor
            dividerColor: root.dividerColor
            focusBorderColor: root.focusColor
            textColor: root.textColor
            mutedText: root.mutedText
            bodyFontFamily: root.bodyFontFamily
            enabled: root.authenticationState !== "pending" && root.authenticationState !== "success"
                     && (!root.auth || !root.auth.processing || root.auth.currentPrompt !== "")
            startupFocus: true
            onAccepted: root.submitLogin()
        }

        TerminalDropDown{
            id: sessionSelection
            Layout.fillWidth: true
            u: root.contentU
            iconText: "\udb80\udf79"
            accent: root.iconColor
            fieldColor: root.fieldColor
            focusFieldColor: root.focusFieldColor
            borderColor: root.fieldBorderColor
            dividerColor: root.dividerColor
            focusBorderColor: root.focusColor
            textColor: root.textColor
            mutedText: root.mutedText
            bodyFontFamily: root.bodyFontFamily
            enabled: root.authenticationState !== "pending" && root.authenticationState !== "success"
            model: root.sessions || []
            textRole: "name"
            onAccepted: root.submitLogin()
        }

        Button {
            id: loginButton
            Layout.fillWidth: true
            Layout.preferredHeight: root.contentU * 4.9
            enabled: root.authenticationState !== "pending"
                     && (!root.auth || !root.auth.processing || root.auth.currentPrompt !== "")
            text: root.auth && root.auth.processing && root.auth.currentPrompt === "" ? "CONNECTING..."
                : root.authenticationState === "pending" ? "AUTHENTICATING..."
                : root.authenticationState === "success" ? "AUTHORIZED"
                : root.authenticationState === "failure" ? "AUTHENTICATION FAILED"
                : "AUTHENTICATE"

            background: Rectangle {
                readonly property color resultColor: root.authenticationState === "success" ? root.green
                                                   : root.authenticationState === "failure" ? root.failureColor
                                                   : loginButton.activeFocus ? "#4AD1E2" : "#287B8D"
                gradient: Gradient {
                    GradientStop {
                        position: 0.0
                        color: root.authenticationState === "success" ? "#1E4934"
                             : root.authenticationState === "failure" ? "#48202B"
                             : loginButton.down ? "#103741"
                             : loginButton.hovered ? "#1D6377" : "#164C5D"
                    }
                    GradientStop {
                        position: 1.0
                        color: root.authenticationState === "success" ? "#173526"
                             : root.authenticationState === "failure" ? "#321922"
                             : loginButton.down ? "#0B2931"
                             : loginButton.hovered ? "#164D5E" : "#103C4A"
                    }
                }
                border.color: resultColor
                border.width: 1
                radius: root.contentU * 0.55

                Behavior on border.color { ColorAnimation { duration: 120 } }

                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: parent.radius
                    anchors.rightMargin: parent.radius
                    height: 1
                    color: "#5578D7E4"
                    opacity: loginButton.down ? 0.3 : 0.6
                }
            }

            contentItem: Item {
                RowLayout {
                    anchors.centerIn: parent
                    spacing: root.contentU * 0.75

                    Text {
                        Layout.alignment: Qt.AlignVCenter
                        text: "\uf20e"
                        color: root.authenticationState === "success" ? root.green
                               : root.authenticationState === "failure" ? root.failureColor
                               : root.cyan
                        opacity: 1
                        font.pixelSize: root.contentU * 2
                    }

                    Text {
                        Layout.alignment: Qt.AlignVCenter
                        text: loginButton.text
                        color: root.authenticationState === "success" ? root.green
                               : root.authenticationState === "failure" ? root.failureColor
                               : "#BFEFF4"
                        font.family: root.titleFontFamily
                        font.pixelSize: root.contentU * 1.75
                        font.letterSpacing: root.contentU * 0.11
                    }
                }
            }

            onClicked: root.submitLogin()
        }

        }
    }
}
