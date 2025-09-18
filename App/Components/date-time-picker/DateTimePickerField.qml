import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI

/*!
    \qmltype DateTimePickerField
    \brief The input field part of the DateTimePicker

    Follows your design system's input styling patterns.
    Separated from main component for better maintainability.
*/

/*!
    \qmltype DateTimePickerField
    \brief The input field part of the DateTimePicker

    Minimal dark input field with underline border to match the design.
*/

/*!
    \qmltype DateTimePickerField
    \brief The input field part of the DateTimePicker

    Minimal dark input field with underline border to match the design.
*/

Rectangle {
    id: root

    // Props from parent
    property bool enabled: true
    property bool isEmpty: true
    property bool isValid: true
    property date selectedDate
    property string placeholderText
    property string dateFormat
    property int fontSize
    property int padding
    property bool focused: false

    // Signals
    signal clicked()

    // Minimal styling - dark background, no side borders
    color: Theme.colors.primary900  // Very dark background

    // Bottom border only (underline effect)
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: focused ? Theme.borders.b2 : Theme.borders.b1
        color: "white"

        // Smooth border transitions
        Behavior on color {
            ColorAnimation {
                duration: Theme.motion.panelTransitionMs
                easing.type: Theme.motion.panelTransitionEasing
            }
        }

        Behavior on height {
            NumberAnimation {
                duration: Theme.motion.panelTransitionMs
                easing.type: Theme.motion.panelTransitionEasing
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: root.padding
        spacing: Theme.spacing.s2

        // Date text
        Text {
            Layout.fillWidth: true
            text: root.isEmpty ? root.placeholderText : Qt.formatDate(root.selectedDate, root.dateFormat)

            font.family: Theme.typography.familySans
            font.pixelSize: root.fontSize
            font.weight: Theme.typography.weightRegular
            color: {
                if (!root.enabled) return Theme.colors.textMuted
                if (root.isEmpty) return Theme.colors.textMuted
                return Theme.colors.text
            }
            verticalAlignment: Text.AlignVCenter
        }

        // Calendar icon - using your SVG asset
        Rectangle {
            Layout.preferredWidth: Theme.icons.sizeMd
            Layout.preferredHeight: Theme.icons.sizeMd
            color: Theme.colors.transparent

            Image {
                anchors.centerIn: parent
                source: "qrc:/App/assets/icons/calendar.svg"
                width: Theme.icons.sizeMd
                height: Theme.icons.sizeMd
                sourceSize.width: Theme.icons.sizeMd
                sourceSize.height: Theme.icons.sizeMd
            }
        }
    }

    // Click handler
    MouseArea {
        anchors.fill: parent
        enabled: root.enabled
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

        onClicked: {
            root.focused = true
            root.clicked()
        }

        onPressed: root.focused = true
    }
}
