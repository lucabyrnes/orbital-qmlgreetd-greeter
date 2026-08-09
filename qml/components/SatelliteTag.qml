import QtQuick 2.15
import QtQuick.Effects

Item {
    id: root

    property real u: 10
    property string name: "SAT"
    property string status: "ACTIVE"
    property color accent: "#55C985"
    readonly property bool unavailable: root.status === "NO LOS"
    readonly property bool acquiring: root.status === "ACQUIRING"
    property string bodyFontFamily: "Inter"

    width: root.u * 14
    height: root.u * 5.0

    Item {
        id: dot
        width: root.u * 1.1
        height: width
        anchors.left: parent.left
        anchors.top: parent.top

        Rectangle {
            id: statusDot
            width: parent.width
            height: width
            radius: width / 2
            color: root.accent
            opacity: root.unavailable ? 0.38 : 1.0
            anchors.centerIn: parent

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: root.accent
                shadowOpacity: root.unavailable ? 0.08 : root.acquiring ? 0.62 : 0.54
                shadowBlur: root.unavailable ? 0.35 : 0.82
                shadowScale: root.unavailable ? 1.15 : 1.62
            }
        }
    }

    Column {
        anchors.left: dot.right
        anchors.leftMargin: root.u * 1
        anchors.top: parent.top
        spacing: root.u * 0.10

        Text {
            text: root.name
            color: root.accent
            opacity: root.unavailable ? 0.42 : 1.0
            font.family: root.bodyFontFamily
            font.pixelSize: root.u * 1.25
            font.bold: true
        }

        Text {
            text: root.status
            color: root.accent
            opacity: root.unavailable ? 0.34 : 0.82
            font.family: root.bodyFontFamily
            font.pixelSize: root.unavailable ? root.u * 1.0 : root.u * 1.12
        }
    }
}
