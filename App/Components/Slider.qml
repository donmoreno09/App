/*!
    \qmltype Slider
    \inqmlmodule App.Components
    \brief A customizable slider component supporting both single-value and range modes.

    Enhanced slider component that can work as a traditional single-value slider or
    as a range slider with two handles for selecting minimum and maximum values.
    Built with Qt Quick's RangeSlider and Slider controls for optimal performance.
*/

import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI

Item {
    id: root

    // Public properties
    property string size: "md"
    property string label: ""
    property bool showValues: true
    property string valuePrefix: ""
    property string valueSuffix: ""
    property int decimalPlaces: 0
    property bool isRange: false

    // Single value properties
    property real value: 50
    property real from: 0
    property real to: 100
    property real stepSize: 1

    // Range properties
    property real firstValue: 25
    property real secondValue: 75

    // Additional properties
    property bool enabled: true
    property color accentColor: Theme.colors.accent500

    // Size configuration
    readonly property var _sizeConfig: ({
        "sm": {
            height: 32,
            handleSize: 16,
            trackHeight: 4,
            fontSize: Theme.typography.fontSize125,
            spacing: Theme.spacing.s2
        },
        "md": {
            height: 36,
            handleSize: 20,
            trackHeight: 6,
            fontSize: Theme.typography.fontSize150,
            spacing: Theme.spacing.s3
        },
        "lg": {
            height: 40,
            handleSize: 24,
            trackHeight: 8,
            fontSize: Theme.typography.fontSize175,
            spacing: Theme.spacing.s3
        }
    })

    readonly property var _currentSize: _sizeConfig[size] || _sizeConfig["md"]

    implicitWidth: 200
    implicitHeight: _layout.implicitHeight

    ColumnLayout {
        id: _layout
        anchors.fill: parent
        spacing: _currentSize.spacing

        // Header with label and values
        RowLayout {
            Layout.fillWidth: true
            visible: root.label || root.showValues
            spacing: Theme.spacing.s2

            // Label
            Text {
                visible: root.label
                text: root.label
                font.family: Theme.typography.familySans
                font.pixelSize: _currentSize.fontSize
                font.weight: Theme.typography.weightMedium
                color: root.enabled ? Theme.colors.text : Theme.colors.textMuted
                Layout.fillWidth: true

                Behavior on color {
                    ColorAnimation { duration: 150; easing.type: Easing.OutCubic }
                }
            }

            // Value(s) display
            RowLayout {
                visible: root.showValues
                spacing: Theme.spacing.s1

                Text {
                    text: root.isRange ? _formatValue(root.firstValue) : _formatValue(root.value)
                    font.family: Theme.typography.familySans
                    font.pixelSize: _currentSize.fontSize
                    font.weight: Theme.typography.weightMedium
                    color: root.enabled ? root.accentColor : Theme.colors.textMuted

                    Behavior on color {
                        ColorAnimation { duration: 150; easing.type: Easing.OutCubic }
                    }
                }

                Text {
                    visible: root.isRange
                    text: " - " + _formatValue(root.secondValue)
                    font.family: Theme.typography.familySans
                    font.pixelSize: _currentSize.fontSize
                    font.weight: Theme.typography.weightMedium
                    color: root.enabled ? root.accentColor : Theme.colors.textMuted

                    Behavior on color {
                        ColorAnimation { duration: 150; easing.type: Easing.OutCubic }
                    }
                }
            }
        }

        // Slider control area
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: _currentSize.height

            // Single value slider
            Slider {
                id: singleSlider
                visible: !root.isRange
                anchors.fill: parent

                from: root.from
                to: root.to
                value: root.value
                stepSize: root.stepSize
                enabled: root.enabled

                onValueChanged: {
                    root.value = value
                }

                background: Rectangle {
                    x: singleSlider.leftPadding
                    y: singleSlider.topPadding + (singleSlider.availableHeight - height) / 2
                    width: singleSlider.availableWidth
                    height: _currentSize.trackHeight
                    radius: height / 2
                    color: singleSlider.enabled ? Theme.colors.grey300 : Theme.colors.grey200

                    Rectangle {
                        width: singleSlider.visualPosition * parent.width
                        height: parent.height
                        radius: height / 2
                        color: singleSlider.enabled ? root.accentColor : Theme.colors.grey400

                        Behavior on color {
                            ColorAnimation { duration: 150; easing.type: Easing.OutCubic }
                        }
                    }

                    Behavior on color {
                        ColorAnimation { duration: 150; easing.type: Easing.OutCubic }
                    }
                }

                handle: Rectangle {
                    x: singleSlider.leftPadding + singleSlider.visualPosition * (singleSlider.availableWidth - width)
                    y: singleSlider.topPadding + (singleSlider.availableHeight - height) / 2
                    width: _currentSize.handleSize
                    height: _currentSize.handleSize
                    radius: width / 2
                    color: singleSlider.enabled ? Theme.colors.white500 : Theme.colors.grey100
                    border.width: 2
                    border.color: singleSlider.enabled ? root.accentColor : Theme.colors.grey400

                    // Shadow effect
                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width + 2
                        height: parent.height + 2
                        radius: width / 2
                        color: "#00000015"
                        z: -1
                        visible: singleSlider.enabled
                    }

                    Behavior on border.color {
                        ColorAnimation { duration: 150; easing.type: Easing.OutCubic }
                    }

                    Behavior on color {
                        ColorAnimation { duration: 150; easing.type: Easing.OutCubic }
                    }
                }
            }

            // Range slider
            RangeSlider {
                id: rangeSlider
                visible: root.isRange
                anchors.fill: parent

                from: root.from
                to: root.to
                first.value: root.firstValue
                second.value: root.secondValue
                stepSize: root.stepSize
                enabled: root.enabled

                first.onValueChanged: {
                    root.firstValue = first.value
                }

                second.onValueChanged: {
                    root.secondValue = second.value
                }

                background: Rectangle {
                    x: rangeSlider.leftPadding
                    y: rangeSlider.topPadding + (rangeSlider.availableHeight - height) / 2
                    width: rangeSlider.availableWidth
                    height: _currentSize.trackHeight
                    radius: height / 2
                    color: rangeSlider.enabled ? Theme.colors.grey300 : Theme.colors.grey200

                    Rectangle {
                        x: rangeSlider.first.visualPosition * parent.width
                        width: (rangeSlider.second.visualPosition - rangeSlider.first.visualPosition) * parent.width
                        height: parent.height
                        radius: height / 2
                        color: rangeSlider.enabled ? root.accentColor : Theme.colors.grey400

                        Behavior on color {
                            ColorAnimation { duration: 150; easing.type: Easing.OutCubic }
                        }
                    }

                    Behavior on color {
                        ColorAnimation { duration: 150; easing.type: Easing.OutCubic }
                    }
                }

                first.handle: Rectangle {
                    x: rangeSlider.leftPadding + rangeSlider.first.visualPosition * (rangeSlider.availableWidth - width)
                    y: rangeSlider.topPadding + (rangeSlider.availableHeight - height) / 2
                    width: _currentSize.handleSize
                    height: _currentSize.handleSize
                    radius: width / 2
                    color: rangeSlider.enabled ? Theme.colors.white500 : Theme.colors.grey100
                    border.width: 2
                    border.color: rangeSlider.enabled ? root.accentColor : Theme.colors.grey400

                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width + 2
                        height: parent.height + 2
                        radius: width / 2
                        color: "#00000015"
                        z: -1
                        visible: rangeSlider.enabled
                    }

                    Behavior on border.color {
                        ColorAnimation { duration: 150; easing.type: Easing.OutCubic }
                    }

                    Behavior on color {
                        ColorAnimation { duration: 150; easing.type: Easing.OutCubic }
                    }
                }

                second.handle: Rectangle {
                    x: rangeSlider.leftPadding + rangeSlider.second.visualPosition * (rangeSlider.availableWidth - width)
                    y: rangeSlider.topPadding + (rangeSlider.availableHeight - height) / 2
                    width: _currentSize.handleSize
                    height: _currentSize.handleSize
                    radius: width / 2
                    color: rangeSlider.enabled ? Theme.colors.white500 : Theme.colors.grey100
                    border.width: 2
                    border.color: rangeSlider.enabled ? root.accentColor : Theme.colors.grey400

                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width + 2
                        height: parent.height + 2
                        radius: width / 2
                        color: "#00000015"
                        z: -1
                        visible: rangeSlider.enabled
                    }

                    Behavior on border.color {
                        ColorAnimation { duration: 150; easing.type: Easing.OutCubic }
                    }

                    Behavior on color {
                        ColorAnimation { duration: 150; easing.type: Easing.OutCubic }
                    }
                }
            }
        }
    }

    // Helper function
    function _formatValue(val) {
        const formattedNumber = val.toFixed(root.decimalPlaces)
        return root.valuePrefix + formattedNumber + root.valueSuffix
    }

    // Accessibility
    Accessible.role: Accessible.Slider
    Accessible.name: root.label || (root.isRange ? "Range Slider" : "Slider")
    Accessible.description: root.isRange ?
        "Range: " + _formatValue(root.firstValue) + " to " + _formatValue(root.secondValue) :
        "Value: " + _formatValue(root.value)
}
