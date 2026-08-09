import QtQuick
import QtQuick.Controls
import "screens"
import OrbitalGreeter 1.0

Window {
    id: root

    width: 2560
    height: 1440
    visible: false
    flags: Qt.FramelessWindowHint
    color: "#050b12"

    LayerShell {
        id: layerShell
        window: root
    }

    AuthWrapper { id: auth }
    SessionModel { id: sessions }
    SystemPower { id: power }
    SystemBattery {
        id: battery
        debugBattery: ConfigDebugBattery
    }

    LoginScreen {
        id: login
        anchors.fill: parent
        auth: auth
        sessions: sessions
        users: userModel
        power: power
        battery: battery
        defaultSession: ConfigDefaultSession
    }

    Component.onCompleted: {
        layerShell.activate()
        root.visible = true
    }
}
