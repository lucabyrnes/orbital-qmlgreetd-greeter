import QtQuick 2.15
import "../components"

Item {
    id: root

    property var auth
    property var sessions
    property var users
    property var power
    property var battery
    property string defaultSession: ""
    property string titleFontFamily: "Eurostile"
    property string bodyFontFamily: "Inter"

    readonly property real u: Math.min(width, height) / 100.0
    readonly property real wUnit: width / 100.0
    readonly property real hUnit: height / 100.0

    QtObject {
        id: palette
        readonly property color panelWash: "#0B1621"
        readonly property color field: "#080F17"
        readonly property color fieldFocus: "#09141D"
        readonly property color transparent: "transparent"
        readonly property color shadow: "#000000"
        readonly property color border: "#52667884"
        readonly property color borderSoft: "#263746"
        readonly property color fieldBorder: "#35434F5B"
        readonly property color divider: "#182633"
        readonly property color cyan: "#22B8CF"
        readonly property color focus: "#35D5E8"
        readonly property color magenta: "#D85A9F"
        readonly property color green: "#55C985"
        readonly property color unavailable: "#60788A"
        readonly property color text: "#DCE6EC"
        readonly property color muted: "#7F92A3"
        readonly property color icon: "#718596"
        readonly property color buttonHover: "#17434E"
        readonly property color cardPanel: "#F2071019"
    }

    Image {
        anchors.fill: parent
        source: "../assets/star_background.jpg"
        fillMode: Image.PreserveAspectCrop
    }

    GlobeScene {
        id: globeScene
        anchors.fill: parent
        u: root.u
        cyan: palette.cyan
        magenta: palette.magenta
        green: palette.green
        unavailable: palette.unavailable
    }

    OrbitOverlay {
        anchors.fill: parent
        u: root.u
        cyan: palette.cyan
        magenta: palette.magenta
        green: palette.green
        muted: palette.unavailable
        satelliteModel: globeScene.satelliteLabels
        groundX: globeScene.groundScreenX
        groundY: globeScene.groundScreenY
        groundVisible: globeScene.groundVisible
        groundName: globeScene.groundName
        groundStatus: globeScene.groundStatus
        titleFontFamily: root.titleFontFamily
        bodyFontFamily: root.bodyFontFamily
    }

    HeaderBar {
        id: header
        z: 20
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: root.wUnit * 1.25
        anchors.rightMargin: root.wUnit * 1.25
        anchors.topMargin: root.hUnit * 2.1
        height: root.hUnit * 8.2
        u: root.u
        title: "ORBITAL NETWORK"
        subtitle: "GROUND STATION ACCESS"
        paletteCyan: palette.cyan
        palettePanel: palette.transparent
        palettePanelWash: palette.panelWash
        paletteShadow: palette.shadow
        paletteBorderGlow: palette.borderSoft
        paletteDivider: palette.divider
        paletteButtonHover: palette.buttonHover
        paletteGreen: palette.green
        paletteText: palette.text
        paletteMuted: palette.muted
        titleFontFamily: root.titleFontFamily
        bodyFontFamily: root.bodyFontFamily
        power: root.power
    }

    Item {
        id: sceneArea
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.leftMargin: root.wUnit * 2.8
        anchors.rightMargin: root.wUnit * 5.9
        anchors.topMargin: root.hUnit * 12.6
        anchors.bottomMargin: root.hUnit * 12.0

        LoginTerminal {
            id: loginTerminal
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: Math.min(root.wUnit * 25.3, sceneArea.width * 0.38)
            height: Math.min(root.hUnit * 52.0, sceneArea.height * 0.78)
            u: root.u
            auth: root.auth
            users: root.users
            sessions: root.sessions
            defaultSession: root.defaultSession
            cyan: palette.cyan
            magenta: palette.magenta
            green: palette.green
            panelColor: palette.cardPanel
            panelWashColor: palette.panelWash
            borderColor: palette.border
            fieldColor: palette.field
            focusFieldColor: palette.fieldFocus
            fieldBorderColor: palette.fieldBorder
            focusColor: palette.focus
            iconColor: palette.icon
            dividerColor: palette.divider
            textColor: palette.text
            mutedText: palette.muted
            titleFontFamily: root.titleFontFamily
            bodyFontFamily: root.bodyFontFamily
        }
    }

    AuthenticationOverlay {
        anchors.fill: parent
        u: root.u
        authenticationState: loginTerminal.authenticationState
        cyan: palette.cyan
        focusColor: palette.focus
        green: palette.green
        failureColor: "#D85A6A"
        textColor: palette.text
        mutedText: palette.muted
        titleFontFamily: root.titleFontFamily
        bodyFontFamily: root.bodyFontFamily
    }

    SystemStatusCard {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: root.wUnit * 2.8
        anchors.bottomMargin: root.hUnit * 3.6
        width: root.wUnit * 16
        height: root.hUnit * 11
        u: root.u
        networkStatus: globeScene.totalSatelliteCount > 0 ? "ONLINE" : "SEARCHING"
        linkStatus: globeScene.satellitesInUse > 0 ? "ESTABLISHED" : "SEARCHING"
        title: palette.cyan
        green: palette.green
        magenta: palette.magenta
        panelColor: palette.cardPanel
        borderColor: palette.borderSoft
        textColor: palette.text
        mutedText: palette.muted
        titleFontFamily: root.titleFontFamily
        bodyFontFamily: root.bodyFontFamily
    }

    ProtocolFooter {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: root.wUnit * 2.8
        anchors.bottomMargin: root.hUnit * 2.25
        width: root.wUnit * 25.2
        height: root.hUnit * 5.8
        u: root.u
        protocolText: "ORBITAL NETWORK PROTOCOL v2.6.1"
        encryptionText: "ENCRYPTION  AES-256"
        nodeText: "LOCAL NODE"
        cyan: palette.cyan
        green: palette.green
        panelColor: palette.transparent
        shieldColor: palette.panelWash
        borderColor: palette.borderSoft
        textColor: palette.text
        mutedText: palette.muted
        bodyFontFamily: root.bodyFontFamily
    }

    Keys.onEscapePressed: function(event) {
        if (!root.auth || loginTerminal.authenticationState === "idle"
                || loginTerminal.authenticationState === "success")
            return
        root.auth.cancel()
        loginTerminal.authenticationState = "idle"
        event.accepted = true
    }
}
