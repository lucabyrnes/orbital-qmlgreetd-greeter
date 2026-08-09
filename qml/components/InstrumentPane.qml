import QtQuick 2.15
import QtQuick.Effects

Item {
    id: root

    property real cornerRadius: 13
    property real inset: 10
    property color surfaceTop: "#F316222C"
    property color surfaceMiddle: "#F009131C"
    property color surfaceBottom: "#F2050D15"
    property color outlineColor: "#52667884"
    property url noiseSource: "../assets/noise-512.png"
    property real contentMargin: 20

    default property alias content: contentContainer.data

    Rectangle {
        id: shadowSource
        anchors.fill: parent
        anchors.margins: root.inset
        radius: root.cornerRadius
        color: "#FF071019"
    }

    MultiEffect {
        anchors.fill: shadowSource
        source: shadowSource
        shadowEnabled: true
        shadowColor: "#000000"
        shadowOpacity: 0.62
        shadowBlur: 0.78
        shadowVerticalOffset: 12
    }

    Rectangle {
        id: surface
        anchors.fill: shadowSource
        radius: root.cornerRadius
        clip: true
        border.width: 1
        border.color: root.outlineColor

        color: "transparent"

        Rectangle {
            anchors.fill: parent
            radius: root.cornerRadius
            gradient: Gradient {
                GradientStop { position: 0.0; color: root.surfaceTop }
                GradientStop { position: 0.50; color: root.surfaceMiddle }
                GradientStop { position: 1.0; color: root.surfaceBottom }
            }
        }

        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 15
            anchors.rightMargin: 15
            height: 1
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "#001A9DB5" }
                GradientStop { position: 0.25; color: "#123B91A5" }
                GradientStop { position: 0.75; color: "#0E5A7888" }
                GradientStop { position: 1.0; color: "#001A9DB5" }
            }
        }

        Image {
            anchors.fill: parent
            source: root.noiseSource
            fillMode: Image.PreserveAspectCrop
            opacity: 0.25
            smooth: false
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 2
            radius: Math.max(0, root.cornerRadius - 2)
            color: "transparent"
            border.width: 1
            border.color: "#142E4858"
        }

        Rectangle {
            anchors.fill: parent
            radius: root.cornerRadius
            color: "transparent"
            border.width: 1
            border.color: root.outlineColor
        }

        Item {
            id: contentContainer
            anchors.fill: parent
            anchors.margins: root.contentMargin
        }
    }
}
