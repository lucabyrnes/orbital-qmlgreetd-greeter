import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root

    property real u: 10
    property string authenticationState: "idle"
    property color cyan: "#22B8CF"
    property color focusColor: "#35D5E8"
    property color green: "#55C985"
    property color failureColor: "#D85A6A"
    property color textColor: "#DCE6EC"
    property color mutedText: "#7F92A3"
    property string titleFontFamily: "Eurostile"
    property string bodyFontFamily: "Inter"
    // Icon-font glyph bearings differ, so each status symbol has its own correction.
    property real checkIconHorizontalOffset: -u * 0.15
    property real failureIconHorizontalOffset: -u * 0.29

    readonly property bool active: authenticationState !== "idle"
    readonly property color stateColor: authenticationState === "success" ? green
                                        : authenticationState === "failure" ? failureColor
                                        : cyan
    readonly property string stateTitle: authenticationState === "success" ? "ACCESS GRANTED"
                                          : authenticationState === "failure" ? "ACCESS DENIED"
                                          : "AUTHORIZING..."
    readonly property string stateSubtitle: authenticationState === "success" ? "Credentials verified"
                                             : authenticationState === "failure" ? "Invalid password — retry required"
                                             : "Checking local credentials"

    visible: opacity > 0
    opacity: active ? 1 : 0
    enabled: active
    z: 100

    Behavior on opacity {
        NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
    }

    Rectangle {
        anchors.fill: parent
        color: "#A0000710"
        opacity: root.authenticationState === "pending" ? 0.48 : 0.43

        Behavior on opacity { NumberAnimation { duration: 150 } }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.AllButtons
        }
    }

    InstrumentPane {
        id: panel
        anchors.centerIn: parent
        width: Math.min(root.u * 57.0, root.width * 0.40)
        height: Math.min(root.u * 13.2, root.height * 0.18)
        cornerRadius: root.u * 0.8
        inset: root.u * 0.8
        contentMargin: 0
        surfaceTop: "#03080D"
        surfaceMiddle: "#03080D"
        surfaceBottom: "#03080D"
        outlineColor: Qt.rgba(root.stateColor.r, root.stateColor.g, root.stateColor.b,
                              root.authenticationState === "pending" ? 0.58 : 0.72)

        scale: root.active ? 1 : 0.975
        Behavior on scale {
            NumberAnimation { duration: 170; easing.type: Easing.OutCubic }
        }

        RowLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.leftMargin: root.u * 4.0
            anchors.rightMargin: root.u * 3.4
            spacing: root.u * 2.8

            Canvas {
                id: authenticationIcon
                Layout.preferredWidth: root.u * 6.5
                Layout.preferredHeight: root.u * 6.5
                Layout.alignment: Qt.AlignVCenter
                antialiasing: true

                property color strokeColor: root.stateColor

                onStrokeColorChanged: requestPaint()
                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()
                onPaint: {
                    const ctx = getContext("2d")
                    ctx.reset()

                    const scale = Math.min(width / 301, height / 351)
                    ctx.translate((width - 301 * scale) / 2,
                                  (height - 351 * scale) / 2)
                    ctx.scale(scale, scale)
                    ctx.strokeStyle = strokeColor
                    ctx.lineWidth = 8
                    ctx.lineJoin = "miter"

                    // Outer orbital-security frame.
                    ctx.beginPath()
                    ctx.moveTo(150.804, 349.942)
                    ctx.lineTo(0.5, 262.942)
                    ctx.lineTo(0.5, 87.442)
                    ctx.lineTo(150.804, 0.576)
                    ctx.lineTo(300.304, 84.942)
                    ctx.lineTo(300.304, 262.942)
                    ctx.closePath()
                    ctx.stroke()

                    // Keep the inner frame quieter than the outer frame and keyhole.
                    ctx.globalAlpha = 0.45
                    ctx.beginPath()
                    ctx.moveTo(25.804, 248.942)
                    ctx.lineTo(25.804, 99.442)
                    ctx.lineTo(150.804, 29.773)
                    ctx.lineTo(275.804, 101.942)
                    ctx.lineTo(275.804, 248.942)
                    ctx.lineTo(150.804, 321.111)
                    ctx.closePath()
                    ctx.stroke()

                    // Central keyhole.
                    ctx.globalAlpha = 1.0
                    ctx.beginPath()
                    ctx.moveTo(110.804, 248.942)
                    ctx.lineTo(188.304, 248.942)
                    ctx.lineTo(173.304, 177.942)
                    ctx.bezierCurveTo(188.304, 170.442, 200.304, 143.942,
                                      187.304, 119.942)
                    ctx.bezierCurveTo(182.804, 112.442, 170.304, 98.442,
                                      151.304, 98.442)
                    ctx.bezierCurveTo(137.804, 98.442, 123.804, 101.442,
                                      112.304, 120.942)
                    ctx.bezierCurveTo(103.804, 133.942, 102.304, 163.542,
                                      126.304, 177.942)
                    ctx.closePath()
                    ctx.stroke()
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: root.u * 0.45

                Text {
                    text: root.stateTitle
                    color: root.textColor
                    font.family: root.titleFontFamily
                    font.pixelSize: root.u * 2.2
                    font.letterSpacing: root.u * 0.08
                    font.weight: Font.Medium
                }

                Text {
                    text: root.stateSubtitle
                    color: root.authenticationState === "pending" ? root.mutedText : root.stateColor
                    font.family: root.bodyFontFamily
                    font.pixelSize: root.u * 1.35
                }
            }

            Item {
                Layout.preferredWidth: root.u * 7.0
                Layout.preferredHeight: root.u * 5.4
                Layout.alignment: Qt.AlignVCenter

                Row {
                    visible: root.authenticationState === "pending"
                    anchors.right: parent.right
                    anchors.rightMargin: -root.u * 2.0
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: root.u * 0.85

                    Repeater {
                        model: 4

                        Rectangle {
                            required property int index
                            width: root.u * 0.42
                            height: root.u * 3.0
                            radius: width / 2
                            color: root.cyan
                            opacity: 0.35

                            SequentialAnimation on opacity {
                                running: root.authenticationState === "pending"
                                loops: Animation.Infinite
                                PauseAnimation { duration: index * 95 }
                                NumberAnimation { from: 0.30; to: 1.0; duration: 240 }
                                NumberAnimation { from: 1.0; to: 0.30; duration: 420 }
                                PauseAnimation { duration: (3 - index) * 95 }
                            }
                        }
                    }
                }

                Rectangle {
                    visible: root.authenticationState === "success"
                             || root.authenticationState === "failure"
                    anchors.right: parent.right
                    anchors.rightMargin: -root.u * 2.0
                    anchors.verticalCenter: parent.verticalCenter
                    width: root.u * 4.4
                    height: width
                    radius: width / 2
                    color: root.stateColor
                    border.width: 1
                    border.color: Qt.lighter(root.stateColor, 1.18)

                    Canvas {
                        id: statusGlyph
                        anchors.centerIn: parent
                        width: root.u * 2.8
                        height: width
                        antialiasing: true

                        onWidthChanged: requestPaint()
                        onHeightChanged: requestPaint()
                        onPaint: {
                            const ctx = getContext("2d")
                            ctx.reset()
                            ctx.scale(width / 100, height / 100)
                            // Match the pane's central surface so the glyph is cut from its backdrop.
                            ctx.strokeStyle = "#09131C"
                            ctx.lineWidth = 12
                            ctx.lineCap = "butt"
                            ctx.lineJoin = "miter"

                            ctx.beginPath()
                            if (root.authenticationState === "failure") {
                                ctx.moveTo(24, 24)
                                ctx.lineTo(76, 76)
                                ctx.moveTo(76, 24)
                                ctx.lineTo(24, 76)
                            } else {
                                ctx.moveTo(15, 53)
                                ctx.lineTo(41, 76)
                                ctx.lineTo(85, 27)
                            }
                            ctx.stroke()
                        }

                        Connections {
                            target: root
                            function onAuthenticationStateChanged() { statusGlyph.requestPaint() }
                        }
                    }
                }
            }
        }

        Item {
            id: bottomRail
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.leftMargin: root.u * 1.4
            anchors.rightMargin: root.u * 1.4
            anchors.bottomMargin: root.u * 0.4
            height: root.u * 0.9
            clip: true

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                height: Math.max(1, root.u * 0.13)
                color: root.stateColor
                opacity: 0.7
            }
        }
    }
}
