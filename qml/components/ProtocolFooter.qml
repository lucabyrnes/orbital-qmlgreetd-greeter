import QtQuick 2.15
import QtQuick.Layouts 1.15

Item {
    id: root

    property real u: 10
    property string protocolText: "ORBITAL NETWORK PROTOCOL v2.6.1"
    property string encryptionText: "ENCRYPTION  AES-256"
    property string nodeText: "LOCAL NODE"
    property color cyan: "#22B8CF"
    property color green: "#55C985"
    property color panelColor: "transparent"
    property color shieldColor: "#0B1621"
    property color borderColor: "#263746"
    property color textColor: "#DCE6EC"
    property color mutedText: "#7F92A3"
    property string bodyFontFamily: "Inter"

    Rectangle {
        anchors.fill: parent
        color: root.panelColor
    }

    RowLayout {
        anchors.fill: parent
        spacing: root.u * 1.25

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: root.u * 0.55

            Text {
                Layout.fillWidth: true
                text: root.protocolText
                color: root.textColor
                opacity: 0.62
                font.family: root.bodyFontFamily
                font.pixelSize: root.u * 1.23
                font.letterSpacing: root.u * 0.05
                horizontalAlignment: Text.AlignRight
            }

            RowLayout {
                visible: root.encryptionText.length > 0 || root.nodeText.length > 0
                Layout.alignment: Qt.AlignRight
                spacing: root.u * 0.75
                Text { text: root.encryptionText; color: root.mutedText; opacity: 0.7; font.family: root.bodyFontFamily; font.pixelSize: root.u * 1.17; font.letterSpacing: root.u * 0.04 }
                Text { text: "•"; color: root.mutedText; opacity: 0.7; font.family: root.bodyFontFamily; font.pixelSize: root.u * 1.17 }
                Text { text: root.nodeText; color: root.mutedText; opacity: 0.7; font.family: root.bodyFontFamily; font.pixelSize: root.u * 1.17; font.letterSpacing: root.u * 0.04 }
            }
        }

        ShieldBadge {
            Layout.preferredWidth: root.u * 6.2
            Layout.preferredHeight: root.u * 6.2
            Layout.alignment: Qt.AlignVCenter
        }
    }

    component ShieldBadge: Image {
        source: "../assets/Sheild.png"
        fillMode: Image.PreserveAspectFit
        mipmap: true
        smooth: true
    }
}
