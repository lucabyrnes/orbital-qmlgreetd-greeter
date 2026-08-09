import QtQuick 2.15
import QtQuick.Layouts 1.15

Item {
    id: root

    property real u: 10
    property string networkStatus: "ONLINE"
    property string linkStatus: "ESTABLISHED"
    property color title: "#22B8CF"
    property color green: "#55C985"
    property color magenta: "#D85A9F"
    property color panelColor: "#F2071019"
    property color borderColor: "#263746"
    property color textColor: "#DCE6EC"
    property color mutedText: "#7F92A3"
    property string titleFontFamily: "Eurostile"
    property string bodyFontFamily: "Inter"
    readonly property real contentU: Math.min(root.u, root.height / 9.0)

    InstrumentPane {
        anchors.fill: parent
        inset: Math.max(1, root.contentU * 0.5)
        cornerRadius: root.contentU * 1.0
        contentMargin: 0
        surfaceTop: "#F316222C"
        surfaceMiddle: "#F009131C"
        surfaceBottom: root.panelColor
        outlineColor: "#52667884"

        ColumnLayout {
            anchors.fill: parent
            anchors.leftMargin: root.contentU * 1.65
            anchors.rightMargin: root.contentU * 1.65
            anchors.topMargin: root.contentU * 1.35
            anchors.bottomMargin: root.contentU * 1.2
            spacing: root.contentU * 0.45

            RowLayout {
                Layout.fillWidth: true
                Layout.bottomMargin: root.contentU * 0.25
                spacing: root.contentU * 0.7

                Rectangle {
                    Layout.preferredWidth: root.contentU * 0.62
                    Layout.preferredHeight: root.contentU * 0.62
                    Layout.alignment: Qt.AlignVCenter
                    radius: width / 2
                    color: root.green
                }

                Text {
                    Layout.alignment: Qt.AlignVCenter
                    text: "SYSTEM STATUS"
                    color: root.textColor
                    font.family: root.titleFontFamily
                    font.pixelSize: root.contentU * 1.5
                    font.letterSpacing: root.contentU * 0.11
                    font.weight: Font.Medium
                    opacity: 0.9
                }
            }

            StatusLine { label: "NETWORK"; value: root.networkStatus; valueColor: root.networkStatus === "ONLINE" ? root.green : root.magenta; u: root.contentU; textColor: root.mutedText; bodyFontFamily: root.bodyFontFamily }
            StatusLine { label: "LINK STATUS"; value: root.linkStatus; valueColor: root.linkStatus === "ESTABLISHED" || root.linkStatus === "ESTABLISHED" ? root.green : root.magenta; u: root.contentU; textColor: root.mutedText; bodyFontFamily: root.bodyFontFamily }
        }
    }

    component StatusLine: RowLayout {
        property real u: 10
        property string label: "LABEL"
        property string value: "VALUE"
        property color valueColor: "#55C985"
        property color textColor: "#7F92A3"
        property string bodyFontFamily: "Inter"

        Layout.fillWidth: true
        Layout.preferredHeight: u * 1.55
        spacing: u * 0.8

        Text {
            Layout.fillWidth: true
            text: label
            color: textColor
            opacity: 0.82
            font.family: bodyFontFamily
            font.pixelSize: u * 1.08
            font.letterSpacing: u * 0.1
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        Text {
            Layout.preferredWidth: u * 11.1
            Layout.minimumWidth: u * 9.2
            text: value
            color: valueColor
            opacity: 0.94
            font.family: bodyFontFamily
            font.pixelSize: u * 1.12
            font.letterSpacing: u * 0.13
            font.weight: Font.Medium
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
    }
}
