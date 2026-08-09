import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15


Item {
    id: root
    property real u: 10
    property alias text: field.text
    property string placeholderText: ""
    property string iconText: "□"
    property bool password: false
    property color accent: "#718596"
    property color fieldColor: "#080F17"
    property color focusFieldColor: "#09141D"
    property color borderColor: "#1C2A36"
    property color dividerColor: "#182633"
    property color focusBorderColor: accent
    property color textColor: "#C8D4DC"
    property color mutedText: "#7F92A3"
    property string bodyFontFamily: "Inter"
    property bool suppressVirtualKeyboard: true
    property bool startupFocus: false
    property color validationColor: "transparent"
    property real validationStrength: 0

    signal accepted()

    function forceActiveFocus() {
        field.forceActiveFocus()
    }

    function clear() {
        field.clear()
    }

    function hideVirtualKeyboard() {
        if (root.suppressVirtualKeyboard && typeof Qt.inputMethod !== "undefined") {
            Qt.inputMethod.hide()
            keyboardSuppressionTimer.restart()
        }
    }

    Layout.fillWidth: true
    Layout.preferredHeight: root.u * 5.2

    Component.onCompleted: {
        if (root.startupFocus) {
            field.forceActiveFocus()
            root.hideVirtualKeyboard()
        }
    }

    Timer {
        id: keyboardSuppressionTimer
        interval: 40
        repeat: false
        onTriggered: {
            if (root.suppressVirtualKeyboard && typeof Qt.inputMethod !== "undefined") {
                Qt.inputMethod.hide()
            }
        }
    }

    Connections {
        target: typeof Qt.inputMethod !== "undefined" ? Qt.inputMethod : null
        ignoreUnknownSignals: true

        function onVisibleChanged() {
            if (root.suppressVirtualKeyboard && Qt.inputMethod.visible) {
                keyboardSuppressionTimer.restart()
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: field.activeFocus ? "#F00B1822" : "#F0081119"
            }
            GradientStop { position: 1.0; color: "#F0050C12" }
        }
        border.color: root.validationStrength > 0
                      ? Qt.rgba(root.validationColor.r, root.validationColor.g, root.validationColor.b, root.validationStrength)
                      : field.activeFocus ? "#354B5966" : root.borderColor
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
            color: field.activeFocus ? root.focusBorderColor : root.accent
            opacity: field.activeFocus ? 0.9 : 0.72
            font.pixelSize: root.u * 1.9
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            Behavior on color { ColorAnimation { duration: 120 } }
            Behavior on opacity { NumberAnimation { duration: 120 } }
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
            width: field.activeFocus || root.validationStrength > 0 ? Math.max(2, root.u * 0.18) : 0
            color: root.validationStrength > 0 ? root.validationColor : root.focusBorderColor
            radius: width / 2
            opacity: root.validationStrength > 0 ? root.validationStrength : 1

            Behavior on width { NumberAnimation { duration: 120 } }
            Behavior on color { ColorAnimation { duration: 120 } }
        }

        Behavior on border.color { ColorAnimation { duration: 120 } }
    }

    TextField {
        id: field
        anchors.fill: parent
        placeholderText: root.placeholderText
        echoMode: root.password ? TextInput.Password : TextInput.Normal
        color: root.textColor
        placeholderTextColor: root.mutedText
        inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase | Qt.ImhSensitiveData
        focusPolicy: Qt.StrongFocus
        selectByMouse: true
        font.family: root.bodyFontFamily
        font.pixelSize: root.u * 1.575
        leftPadding: root.u * 5.85
        rightPadding: root.u * 1.35
        cursorDelegate: Rectangle {
            width: Math.max(1, root.u * 0.12)
            color: root.focusBorderColor
        }

        background: Item { }

        Keys.onReturnPressed: root.accepted()
        Keys.onEnterPressed: root.accepted()
        Keys.onPressed: root.hideVirtualKeyboard()
        onActiveFocusChanged: if (activeFocus) root.hideVirtualKeyboard()
        onPressed: root.hideVirtualKeyboard()
    }
}
