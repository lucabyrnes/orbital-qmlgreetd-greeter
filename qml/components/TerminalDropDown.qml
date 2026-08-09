import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root

    property real u: 10
    property string iconText: "\udb80\udf79"
    property color accent: "#718596"
    property color fieldColor: "#080F17"
    property color focusFieldColor: "#09141D"
    property color borderColor: "#1C2A36"
    property color dividerColor: "#182633"
    property color focusBorderColor: accent
    property color textColor: "#C8D4DC"
    property color mutedText: "#7F92A3"
    property string bodyFontFamily: "Inter"
    property color validationColor: "transparent"
    property real validationStrength: 0
    property alias model: selector.model
    property alias textRole: selector.textRole
    property alias valueRole: selector.valueRole
    property alias currentIndex: selector.currentIndex
    readonly property alias currentText: selector.currentText
    readonly property alias currentValue: selector.currentValue

    signal accepted()
    signal selectionActivated()

    function forceActiveFocus() {
        selector.forceActiveFocus()
    }

    Layout.fillWidth: true
    Layout.preferredHeight: root.u * 5.2

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: selector.activeFocus || selector.popup.visible ? "#F00B1822" : "#F0081119"
            }
            GradientStop { position: 1.0; color: "#F0050C12" }
        }
        border.color: root.validationStrength > 0
                      ? Qt.rgba(root.validationColor.r, root.validationColor.g, root.validationColor.b, root.validationStrength)
                      : selector.activeFocus || selector.popup.visible ? "#354B5966" : root.borderColor
        border.width: 1
        radius: root.u * 0.5

        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: Math.max(0, parent.radius - 1)
            color: "transparent"
            border.width: 1
            border.color: "#102F4655"
        }

        Text {
            width: root.u * 4.6
            height: parent.height
            anchors.left: parent.left
            text: root.iconText
            color: root.validationStrength > 0 ? root.validationColor
                 : selector.activeFocus || selector.popup.visible ? root.focusBorderColor : root.accent
            opacity: selector.activeFocus || selector.popup.visible ? 0.9 : 0.72
            font.pixelSize: root.u * 1.9
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Rectangle {
            x: root.u * 4.6
            anchors.verticalCenter: parent.verticalCenter
            width: 1
            height: parent.height * 0.46
            color: root.dividerColor
        }

        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: selector.activeFocus || selector.popup.visible || root.validationStrength > 0
                   ? Math.max(2, root.u * 0.18) : 0
            color: root.validationStrength > 0 ? root.validationColor : root.focusBorderColor
            opacity: root.validationStrength > 0 ? root.validationStrength : 1
            radius: width / 2
            Behavior on width { NumberAnimation { duration: 120 } }
        }

        Behavior on border.color { ColorAnimation { duration: 120 } }
    }

    ComboBox {
        id: selector

        anchors.fill: parent
        hoverEnabled: true
        wheelEnabled: true

        contentItem: Text {
            leftPadding: root.u * 5.85
            rightPadding: selector.indicator.width + root.u * 1.8
            text: selector.displayText
            color: root.textColor
            opacity: selector.enabled ? 0.94 : 0.45
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            font.family: root.bodyFontFamily
            font.pixelSize: root.u * 1.575
        }

        indicator: Item {
            x: selector.width - width - root.u * 1.0
            y: (selector.height - height) / 2
            width: root.u * 2.0
            height: root.u * 2.0

            Text {
                anchors.centerIn: parent
                text: selector.popup.visible ? "▲" : "▼"
                color: selector.activeFocus || selector.hovered || selector.popup.visible
                       ? root.focusBorderColor
                       : root.mutedText
                font.family: root.bodyFontFamily
                font.pixelSize: root.u * 1.05
            }
        }

        background: Item { }

        delegate: ItemDelegate {
            id: option

            required property int index
            width: selector.width - selector.popup.leftPadding - selector.popup.rightPadding
            height: root.u * 4.35
            hoverEnabled: true
            highlighted: selector.highlightedIndex === index

            contentItem: Text {
                leftPadding: root.u * 0.8
                rightPadding: root.u * 0.8
                text: selector.textAt(option.index)
                color: option.highlighted ? root.focusBorderColor : root.textColor
                opacity: option.enabled ? 0.94 : 0.45
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                font.family: root.bodyFontFamily
                font.pixelSize: root.u * 1.5
            }

            background: Rectangle {
                color: option.highlighted || option.hovered
                       ? "#0B1621"
                       : "transparent"
                border.color: option.highlighted
                              ? root.dividerColor
                              : "transparent"
                border.width: 1
                radius: root.u * 0.35
            }
        }

        popup: Popup {
            y: selector.height + root.u * 0.35
            width: selector.width
            implicitHeight: Math.min(contentItem.implicitHeight + topPadding + bottomPadding, root.u * 22.5)
            topPadding: root.u * 0.45
            bottomPadding: root.u * 0.45
            leftPadding: root.u * 0.45
            rightPadding: root.u * 0.45

            contentItem: ListView {
                clip: true
                implicitHeight: contentHeight
                model: selector.popup.visible ? selector.delegateModel : null
                currentIndex: selector.highlightedIndex
                highlightMoveDuration: 80
                ScrollIndicator.vertical: ScrollIndicator { }
            }

            background: Rectangle {
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#F00B151E" }
                    GradientStop { position: 1.0; color: "#F2071018" }
                }
                border.color: "#52667884"
                border.width: 1
                radius: root.u * 0.5
            }
        }

        Keys.onReturnPressed: function(event) {
            if (!selector.popup.visible) {
                root.accepted()
                event.accepted = true
            }
        }
        Keys.onEnterPressed: function(event) {
            if (!selector.popup.visible) {
                root.accepted()
                event.accepted = true
            }
        }
        onActivated: root.selectionActivated()
    }
}
