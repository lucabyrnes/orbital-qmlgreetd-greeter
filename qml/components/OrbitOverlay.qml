import QtQuick 2.15
import QtQuick.Effects

Item {
    id: root

    property real u: 10
    property color cyan: "#22B8CF"
    property color magenta: "#D85A9F"
    property color green: "#55C985"
    property color muted: "#60788A"
    property var satelliteModel: []
    property string titleFontFamily: "Eurostile"
    property string bodyFontFamily: "Inter"

    property real groundX: width * 0.42
    property real groundY: height * 0.58
    property bool groundVisible: true
    property string groundName: "HELIOS BASIN"
    property string groundStatus: "LOCAL NODE"

    Repeater {
        model: root.satelliteModel
        delegate: SatelliteTag {
            x: model.x - root.u * 0.55
            y: model.y - root.u * 0.55
            visible: model.visible
            u: root.u
            name: model.name
            status: model.status
            // Resolve the semantic color at the presentation boundary instead
            // of relying on a dynamically stored ListModel color role.
            accent: model.status === "ACTIVE" ? root.green
                    : model.status === "ACQUIRING" ? root.magenta
                    : root.muted
            bodyFontFamily: root.bodyFontFamily
        }
    }

    Item {
        x: root.groundX - root.u * 1.25
        y: root.groundY - height / 2
        visible: root.groundVisible
        width: root.u * 15
        height: root.u * 6

        Item {
            id: groundMarker
            width: root.u * 1.5
            height: width
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter

            // Image {
            //     id: groundIconMask
            //     width: root.u * 3.5
            //     height: width
            //     source: "../assets/ground_dish.png"
            //     fillMode: Image.PreserveAspectFit
            //     mipmap: true
            //     smooth: true
            //     anchors.centerIn: parent
            //     visible: false
            // }

            // MultiEffect {
            //     anchors.fill: groundIconMask
            //     source: groundIconMask
            //     maskEnabled: true
            //     maskSource: groundIconMask
            //     colorization: 1.0
            //     colorizationColor: root.cyan
            // }

            Rectangle {
            id: statusDot
            width: parent.width
            height: width
            radius: width / 2
            color: root.cyan
            anchors.centerIn: parent

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: root.cyan
                shadowOpacity: 0.42
                shadowBlur: 0.75
                shadowScale: 1.45
            }
        }

        }

        // Column {
        //     anchors.left: parent.left
        //     anchors.leftMargin: root.u * 4.0
        //     anchors.verticalCenter: parent.verticalCenter
        //     spacing: root.u * 0.10

        //     Text {
        //         text: root.groundName
        //         color: root.cyan
        //         font.pixelSize: root.u * 1.00
        //         font.bold: true
        //     }
        // }
    }
}
