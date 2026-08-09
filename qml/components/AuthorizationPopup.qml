import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property string authState: "idle"
    property string detail: ""
    property color cyan: "#22b8cf"
    property color green: "#55c985"
    property color red: "#d85a6a"
    property color textColor: "#dce6ec"
    property color mutedColor: "#7f92a3"
    property string titleFont: "Eurostile"
    property string bodyFont: "Inter"

    readonly property bool active: authState !== "idle" && authState !== "awaitingResponse"
    readonly property color stateColor: authState === "success" ? green : authState === "failure" ? red : cyan
    readonly property string title: authState === "success" ? "ACCESS GRANTED"
                                  : authState === "failure" ? "ACCESS DENIED" : "AUTHORIZING"
    readonly property string subtitle: authState === "success" ? "SESSION VERIFIED"
                                     : authState === "failure" ? (detail || "TRY AGAIN") : "VERIFYING ACCESS"

    anchors.fill: parent
    visible: opacity > 0
    opacity: active ? 1 : 0
    z: 20

    Behavior on opacity {
        NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
    }

    Rectangle {
        anchors.fill: parent
        color: "#a0000710"
        opacity: root.authState === "authenticating" ? 0.44 : 0.32
    }

    OrbitalPanel {
        anchors.centerIn: parent
        width: Math.min(parent.width * 0.42, 500)
        height: 150
        panelColor: "#f5101c28"
        borderColor: root.stateColor

        RowLayout {
            anchors.fill: parent
            anchors.margins: 30
            spacing: 22

            DishGlyph {
                Layout.preferredWidth: 74
                Layout.preferredHeight: 74
                status: root.authState
                primaryColor: root.cyan
                failureColor: root.red
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: root.title
                    color: root.textColor
                    font.family: root.titleFont
                    font.pixelSize: 22
                    font.letterSpacing: 1.8
                    font.weight: Font.Medium
                }

                Text {
                    Layout.fillWidth: true
                    text: root.subtitle
                    color: root.authState === "authenticating" ? root.mutedColor : root.stateColor
                    font.family: root.bodyFont
                    font.pixelSize: 13
                    font.letterSpacing: 1
                    wrapMode: Text.WordWrap
                }
            }
        }
    }
}
