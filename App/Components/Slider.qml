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
    property bool isDotted: false

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
        "sm": { height: 32, handleSize: 16, trackHeight: 4, fontSize: Theme.typography.fontSize125, spacing: Theme.spacing.s2 },
        "md": { height: 36, handleSize: 20, trackHeight: 6, fontSize: Theme.typography.fontSize150, spacing: Theme.spacing.s3 },
        "lg": { height: 40, handleSize: 24, trackHeight: 8, fontSize: Theme.typography.fontSize175, spacing: Theme.spacing.s3 }
    })

    readonly property var _currentSize: _sizeConfig[size] || _sizeConfig["md"]

    implicitWidth: 200
    implicitHeight: _layout.implicitHeight

    // Micro-components
    component ValueDisplay: RowLayout {
        property bool isRange
        property real value
        property real firstValue
        property real secondValue
        property real fontSize
        property color color
        property string valuePrefix
        property string valueSuffix
        property int decimalPlaces

        spacing: Theme.spacing.s1

        Text {
            text: isRange ? _formatValue(firstValue) : _formatValue(value)
            font.family: Theme.typography.familySans
            font.pixelSize: fontSize
            font.weight: Theme.typography.weightMedium
            color: parent.color

            Behavior on color { ColorAnimation { duration: 150; easing.type: Easing.OutCubic } }
        }

        Text {
            visible: isRange
            text: " - " + _formatValue(secondValue)
            font.family: Theme.typography.familySans
            font.pixelSize: fontSize
            font.weight: Theme.typography.weightMedium
            color: parent.color

            Behavior on color { ColorAnimation { duration: 150; easing.type: Easing.OutCubic } }
        }

        function _formatValue(val) {
            return valuePrefix + val.toFixed(decimalPlaces) + valueSuffix
        }
    }

    component SliderTrack: Item {
        property var slider
        property real trackHeight
        property color accentColor
        property bool isDotted
        property bool isRange

        x: slider.leftPadding
        y: slider.topPadding + (slider.availableHeight - trackHeight) / 2
        width: slider.availableWidth
        height: trackHeight

        Rectangle {
            anchors.fill: parent
            radius: height / 2
            color: slider.enabled ? Theme.colors.grey300 : Theme.colors.grey200
            visible: !isDotted

            Rectangle {
                x: isRange ? slider.first.visualPosition * parent.width : 0
                width: isRange ?
                    (slider.second.visualPosition - slider.first.visualPosition) * parent.width :
                    slider.visualPosition * parent.width
                height: parent.height
                radius: height / 2
                color: slider.enabled ? accentColor : Theme.colors.grey400
            }
        }

        Repeater {
            model: isDotted ? Math.floor(parent.width / 6) : 0
            delegate: Rectangle {
                width: 4
                height: parent.height
                x: index * 6
                color: {
                    if (isRange) {
                        return (x >= slider.first.visualPosition * parent.width &&
                                x <= slider.second.visualPosition * parent.width) ?
                            accentColor : (slider.enabled ? Theme.colors.grey300 : Theme.colors.grey200)
                    } else {
                        return x <= slider.visualPosition * parent.width ?
                            accentColor : (slider.enabled ? Theme.colors.grey300 : Theme.colors.grey200)
                    }
                }
            }
        }
    }

    component SliderHandle: Rectangle {
        property var slider
        property bool isFirst: true
        property real handleSize
        property color accentColor

        x: slider.leftPadding + (isFirst ? slider.first?.visualPosition ?? slider.visualPosition : slider.second.visualPosition) * (slider.availableWidth - width)
        y: slider.topPadding + (slider.availableHeight - height) / 2
        width: handleSize
        height: handleSize
        radius: width / 2
        color: slider.enabled ? Theme.colors.white500 : Theme.colors.grey100
        border.width: 2
        border.color: slider.enabled ? accentColor : Theme.colors.grey400

        Rectangle {
            anchors.centerIn: parent
            width: parent.width + 2
            height: parent.height + 2
            radius: width / 2
            color: "#00000015"
            z: -1
            visible: slider.enabled
        }

        Behavior on border.color { ColorAnimation { duration: 150; easing.type: Easing.OutCubic } }
        Behavior on color { ColorAnimation { duration: 150; easing.type: Easing.OutCubic } }
    }

    ColumnLayout {
        id: _layout
        anchors.fill: parent
        spacing: _currentSize.spacing

        // Header
        RowLayout {
            Layout.fillWidth: true
            visible: root.label || root.showValues
            spacing: Theme.spacing.s2

            Text {
                visible: root.label
                text: root.label
                font.family: Theme.typography.familySans
                font.pixelSize: _currentSize.fontSize
                font.weight: Theme.typography.weightMedium
                color: root.enabled ? Theme.colors.text : Theme.colors.textMuted
                Layout.fillWidth: true

                Behavior on color { ColorAnimation { duration: 150; easing.type: Easing.OutCubic } }
            }

            ValueDisplay {
                visible: root.showValues
                isRange: root.isRange
                value: root.value
                firstValue: root.firstValue
                secondValue: root.secondValue
                fontSize: _currentSize.fontSize
                color: root.enabled ? root.accentColor : Theme.colors.textMuted
                valuePrefix: root.valuePrefix
                valueSuffix: root.valueSuffix
                decimalPlaces: root.decimalPlaces
            }
        }

        // Slider control area
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: _currentSize.height

            Slider {
                id: singleSlider
                visible: !root.isRange
                anchors.fill: parent
                from: root.from
                to: root.to
                value: root.value
                stepSize: root.stepSize
                enabled: root.enabled

                onValueChanged: root.value = value

                background: SliderTrack {
                    slider: singleSlider
                    trackHeight: _currentSize.trackHeight
                    accentColor: root.accentColor
                    isDotted: root.isDotted
                    isRange: false
                }

                handle: SliderHandle {
                    slider: singleSlider
                    handleSize: _currentSize.handleSize
                    accentColor: root.accentColor
                }
            }

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

                first.onValueChanged: root.firstValue = first.value
                second.onValueChanged: root.secondValue = second.value

                background: SliderTrack {
                    slider: rangeSlider
                    trackHeight: _currentSize.trackHeight
                    accentColor: root.accentColor
                    isDotted: root.isDotted
                    isRange: true
                }

                first.handle: SliderHandle {
                    slider: rangeSlider
                    isFirst: true
                    handleSize: _currentSize.handleSize
                    accentColor: root.accentColor
                }

                second.handle: SliderHandle {
                    slider: rangeSlider
                    isFirst: false
                    handleSize: _currentSize.handleSize
                    accentColor: root.accentColor
                }
            }
        }
    }

    function _formatValue(val) {
        return root.valuePrefix + val.toFixed(root.decimalPlaces) + root.valueSuffix
    }
}
