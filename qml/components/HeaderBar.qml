import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root

    property real u: 10
    property string title: "TITLE"
    property string subtitle: "SUBTITLE"
    property color paletteCyan: "#22B8CF"
    property color palettePanel: "transparent"
    property color palettePanelWash: "#0B1621"
    property color paletteShadow: "#000000"
    property color borderColor: "#263746"
    property color paletteBorderGlow: "#263746"
    property color paletteDivider: "#182633"
    property color paletteButtonHover: "#17434E"
    property color paletteGreen: "#55C985"
    property color paletteText: "#DCE6EC"
    property color paletteMuted: "#7F92A3"
    property string titleFontFamily: "Eurostile"
    property string bodyFontFamily: "Inter"
    property date now: new Date()
    property var power

    color: palettePanel
    radius: 0
    border.color: "transparent"
    border.width: 0

    function pad2(value) {
        return value < 10 ? "0" + value : "" + value
    }

    function formatTime(value) {
        return pad2(value.getHours()) + ":" + pad2(value.getMinutes()) + ":" + pad2(value.getSeconds())
    }

    function formatDate(value) {
        const months = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
        return months[value.getMonth()] + " " + pad2(value.getDate()) + ", " + value.getFullYear()
    }

    function invokeAction(label, methods) {
        if (!root.power)
            return

        for (let i = 0; i < methods.length; ++i) {
            const methodName = methods[i]
            if (typeof root.power[methodName] === "function") {
                root.power[methodName]()
                return
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.now = new Date()
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: root.u * 1.5
        anchors.rightMargin: root.u * 1.4
        spacing: root.u * 1.0

        DishGlyph {
            Layout.preferredWidth: root.u * 5.1
            Layout.preferredHeight: root.u * 5.1
            Layout.alignment: Qt.AlignVCenter
            primaryColor: root.paletteCyan
            secondaryColor: root.paletteText
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignVCenter
            spacing: root.u * 0.25

            Text {
                text: root.title
                color: root.paletteText
                font.family: root.titleFontFamily
                font.pixelSize: root.u * 2.925
                font.letterSpacing: root.u * 0.14
                font.weight: Font.Medium
            }

            Text {
                text: root.subtitle
                color: root.paletteMuted
                opacity: 0.92
                font.family: root.bodyFontFamily
                font.pixelSize: root.u * 1.5
                font.letterSpacing: root.u * 0.08
            }
        }

        Item { Layout.fillWidth: true }

        ColumnLayout {
            Layout.alignment: Qt.AlignVCenter
            spacing: root.u * 0.25

            Text {
                Layout.alignment: Qt.AlignRight
                text: root.formatTime(root.now)
                color: root.paletteText
                font.family: root.bodyFontFamily
                font.pixelSize: root.u * 3.5
                font.weight: Font.Light
                font.letterSpacing: root.u * 0.1
            }

            RowLayout {
                Layout.alignment: Qt.AlignRight
                spacing: root.u * 0.9

                Text {
                    text: root.formatDate(root.now)
                    color: root.paletteMuted
                    font.family: root.bodyFontFamily
                    font.pixelSize: root.u * 1.38
                    font.letterSpacing: root.u * 0.08
                }

                Text {
                    text: "LOCAL"
                    color: root.paletteMuted
                    opacity: 0.78
                    font.family: root.bodyFontFamily
                    font.pixelSize: root.u * 1.38
                    font.letterSpacing: root.u * 0.10
                }
            }
        }

        PowerMenu {
            Layout.leftMargin: root.u * 1.85
            u: root.u
            textColor: root.paletteMuted
            hoverTextColor: root.paletteText
            iconColor: root.paletteMuted
            borderGlowColor: root.paletteBorderGlow
            hoverFillColor: root.paletteButtonHover
            panelColor: root.palettePanelWash
            bodyFontFamily: root.bodyFontFamily
            onPowerActionRequested: (label, methods) => root.invokeAction(label, methods)
        }
    }

    component HeaderDivider: Rectangle {
        property real u: 10
        property color dividerColor: "#182633"
        Layout.preferredWidth: Math.max(1, u * 0.08)
        Layout.preferredHeight: u * 4.2
        Layout.alignment: Qt.AlignVCenter
        color: Qt.rgba(dividerColor.r, dividerColor.g, dividerColor.b, 0.74)
    }

    component PowerButton: Button {
        id: actionButton
        property real u: 10
        property string label: "ACTION"
        property string iconText: "•"
        property color textColor: "#7F92A3"
        property color hoverTextColor: "#DCE6EC"
        property color iconColor: "#718596"
        property color hoverFillColor: "#17434E"
        property color borderGlowColor: "#263746"
        property string bodyFontFamily: "Inter"
        signal activated()

        Layout.preferredWidth: u * 13.0
        Layout.preferredHeight: u * 5.2
        Layout.alignment: Qt.AlignVCenter
        hoverEnabled: true
        flat: true
        background: Rectangle {
            color: actionButton.hovered ? Qt.rgba(actionButton.hoverFillColor.r, actionButton.hoverFillColor.g, actionButton.hoverFillColor.b, 0.45) : "transparent"
            border.color: actionButton.activeFocus ? "#35D5E8" : actionButton.hovered ? actionButton.borderGlowColor : "transparent"
            border.width: Math.max(1, actionButton.u * 0.04)
            radius: actionButton.u * 0.32
        }
        contentItem: Item {
            RowLayout {
                anchors.centerIn: parent
                spacing: actionButton.u * 0.85
                Text {
                    Layout.alignment: Qt.AlignVCenter
                    text: actionButton.iconText
                    color: actionButton.iconColor
                    opacity: actionButton.hovered ? 1.0 : 0.88
                    font.pixelSize: actionButton.u * 4.0
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    Layout.alignment: Qt.AlignVCenter
                    text: actionButton.label
                    color: actionButton.hovered ? actionButton.hoverTextColor : actionButton.textColor
                    opacity: actionButton.hovered ? 1.0 : 0.86
                    font.family: actionButton.bodyFontFamily
                    font.pixelSize: actionButton.u * 1.3
                    font.bold: true
                    font.letterSpacing: actionButton.u * 0.06
                }
            }
        }
        onClicked: activated()
    }

    component PowerMenu: Item {
        id: menuRoot
        property real u: 10
        property color textColor: "#7F92A3"
        property color hoverTextColor: "#DCE6EC"
        property color iconColor: "#718596"
        property color hoverFillColor: "#17434E"
        property color borderGlowColor: "#263746"
        property color panelColor: "#0B1621"
        property string bodyFontFamily: "Inter"
        property bool expanded: false
        signal powerActionRequested(string label, var methods)

        Layout.preferredWidth: u * 7.8
        Layout.preferredHeight: u * 6.4
        Layout.alignment: Qt.AlignVCenter
        z: 50

        Button {
            id: toggle
            anchors.fill: parent
            hoverEnabled: true
            flat: true
            padding: 0
            leftPadding: 0
            rightPadding: 0
            topPadding: 0
            bottomPadding: 0
            background: Item {
                InstrumentPane {
                    anchors.fill: parent
                    inset: Math.max(1, menuRoot.u * 0.12)
                    cornerRadius: menuRoot.u * 1.05
                    contentMargin: 0
                    outlineColor: menuRoot.borderGlowColor
                }

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: Math.max(1, menuRoot.u * 0.12)
                    radius: menuRoot.u * 1.05
                    color: toggle.hovered || menuRoot.expanded
                           ? Qt.rgba(menuRoot.hoverFillColor.r, menuRoot.hoverFillColor.g, menuRoot.hoverFillColor.b, 0.24)
                           : "transparent"
                }
            }
            contentItem: Item {
                anchors.fill: parent
                RowLayout {
                    anchors.centerIn: parent
                    spacing: menuRoot.u * 0.65
                    Image {
                        Layout.alignment: Qt.AlignVCenter
                        Layout.preferredWidth: menuRoot.u * 3.0
                        Layout.preferredHeight: menuRoot.u * 3.0
                        source: "../assets/power-shutdown.svg"
                        sourceSize.width: Math.round(menuRoot.u * 3.0)
                        sourceSize.height: Math.round(menuRoot.u * 3.0)
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        mipmap: true
                        opacity: toggle.hovered || menuRoot.expanded ? 1.0 : 0.88
                    }
                    Text { Layout.alignment: Qt.AlignVCenter; Layout.preferredWidth: menuRoot.u * 1.8; text: menuRoot.expanded ? "⌃" : "⌄"; color: menuRoot.textColor; font.pixelSize: menuRoot.u * 2.55; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                }
            }
            onClicked: menuRoot.expanded = !menuRoot.expanded
        }

        Item {
            id: popup
            anchors.right: parent.right
            anchors.top: parent.bottom
            anchors.topMargin: menuRoot.u * 0.45
            width: menuRoot.u * 16.5
            height: menuRoot.expanded ? menuColumn.implicitHeight + menuRoot.u * 2.4 : 0
            visible: height > 0
            clip: true
            z: 100

            Behavior on height { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

            InstrumentPane {
                anchors.fill: parent
                inset: Math.max(1, menuRoot.u * 0.16)
                cornerRadius: menuRoot.u * 1.05
                contentMargin: 0
                outlineColor: menuRoot.borderGlowColor
            }

            ColumnLayout {
                id: menuColumn
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.leftMargin: menuRoot.u * 1.15
                anchors.rightMargin: menuRoot.u * 1.15
                anchors.topMargin: menuRoot.u * 1.2
                spacing: menuRoot.u * 0.45

                PowerMenuItem { label: "SHUTDOWN"; iconSource: "../assets/power-shutdown.svg"; u: menuRoot.u; textColor: menuRoot.textColor; hoverTextColor: menuRoot.hoverTextColor; hoverFillColor: menuRoot.hoverFillColor; bodyFontFamily: menuRoot.bodyFontFamily; onActivated: { menuRoot.expanded = false; menuRoot.powerActionRequested(label, ["powerOff"]) } }
                PowerMenuItem { label: "RESTART"; iconSource: "../assets/power-restart.svg"; u: menuRoot.u; textColor: menuRoot.textColor; hoverTextColor: menuRoot.hoverTextColor; hoverFillColor: menuRoot.hoverFillColor; bodyFontFamily: menuRoot.bodyFontFamily; onActivated: { menuRoot.expanded = false; menuRoot.powerActionRequested(label, ["reboot"]) } }
                PowerMenuItem { label: "SUSPEND"; iconSource: "../assets/power-suspend.svg"; u: menuRoot.u; textColor: menuRoot.textColor; hoverTextColor: menuRoot.hoverTextColor; hoverFillColor: menuRoot.hoverFillColor; bodyFontFamily: menuRoot.bodyFontFamily; onActivated: { menuRoot.expanded = false; menuRoot.powerActionRequested(label, ["suspend"]) } }
                PowerMenuItem { label: "HIBERNATE"; iconSource: "../assets/power-hibernate.svg"; u: menuRoot.u; textColor: menuRoot.textColor; hoverTextColor: menuRoot.hoverTextColor; hoverFillColor: menuRoot.hoverFillColor; bodyFontFamily: menuRoot.bodyFontFamily; onActivated: { menuRoot.expanded = false; menuRoot.powerActionRequested(label, ["hibernate"]) } }
            }
        }
    }

    component PowerMenuItem: Button {
        id: menuItem
        property real u: 10
        property string label: "ACTION"
        property url iconSource
        property color textColor: "#7F92A3"
        property color hoverTextColor: "#DCE6EC"
        property color hoverFillColor: "#17434E"
        property string bodyFontFamily: "Inter"
        signal activated()

        Layout.fillWidth: true
        Layout.preferredHeight: u * 4.25
        hoverEnabled: true
        flat: true
        background: Rectangle { color: menuItem.hovered ? Qt.rgba(menuItem.hoverFillColor.r, menuItem.hoverFillColor.g, menuItem.hoverFillColor.b, 0.52) : "transparent"; radius: menuItem.u * 0.65 }
        contentItem: Item {
            anchors.fill: parent

            RowLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: menuItem.u * 1.15
                anchors.rightMargin: menuItem.u * 1.15
                spacing: menuItem.u * 0.95

                Image {
                    Layout.preferredWidth: menuItem.u * 2.6
                    Layout.preferredHeight: menuItem.u * 2.6
                    Layout.alignment: Qt.AlignVCenter
                    source: menuItem.iconSource
                    sourceSize.width: Math.round(menuItem.u * 2.6)
                    sourceSize.height: Math.round(menuItem.u * 2.6)
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    mipmap: true
                    opacity: menuItem.hovered ? 1.0 : 0.88
                }

                Text {
                    Layout.alignment: Qt.AlignVCenter
                    text: menuItem.label
                    color: menuItem.hovered ? menuItem.hoverTextColor : menuItem.textColor
                    font.family: menuItem.bodyFontFamily
                    font.pixelSize: menuItem.u * 1.5
                    font.bold: true
                    font.letterSpacing: menuItem.u * 0.05
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
        onClicked: activated()
    }
}
