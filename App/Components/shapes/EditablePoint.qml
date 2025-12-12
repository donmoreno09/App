import QtQuick 6.8
import QtQuick.Effects 6.8
import QtLocation 6.8
import QtPositioning 6.8

import App.Themes 1.0

MapQuickItem {
    id: root
    z: Theme.elevation.z100

    // External bindings
    property bool isEditing: false
    property bool tapEnabled: false
    property bool showLabel: true
    property bool showHighlight: true
    property bool highlightOnEditing: true
    property string iconSource: "qrc:/App/assets/icons/poi.svg"
    property int iconWidth: 24
    property int iconHeight: 24
    property string labelText: ""
    property color labelFillColor: Theme.colors.hexWithAlpha("#539E07", 0.6)
    property color labelBorderColor: Theme.colors.white
    property color labelTextColor: Theme.colors.white
    property real labelBorderWidth: Theme.borders.b1
    property color highlightColor: "white"
    property real highlightScale: 1.12

    property bool isDragging: false

    signal tapped()
    signal pointChanged(geoCoordinate coord)

    anchorPoint.x: marker.width / 2
    anchorPoint.y: icon.height / 2

    sourceItem: Column {
        id: marker
        spacing: Theme.spacing.s1
        width: Math.max(icon.width, labelBox.visible ? labelBox.width : 0)

        Image {
            id: icon
            width: root.iconWidth
            height: root.iconHeight
            source: root.iconSource
            smooth: true
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            cache: true

            layer.enabled: root.showHighlight && (!root.highlightOnEditing || root.isEditing)
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: root.highlightColor
                shadowBlur: 0.0            // 0 = sharp edge
                shadowHorizontalOffset: 0
                shadowVerticalOffset: 0
                shadowScale: root.highlightScale
            }
        }

        Rectangle {
            id: labelBox
            visible: root.showLabel && root.labelText !== ""
            anchors.horizontalCenter: icon.horizontalCenter
            width: text.width + Theme.spacing.s3
            height: text.height + Theme.spacing.s1
            radius: Theme.radius.sm
            color: root.labelFillColor
            border.color: root.labelBorderColor
            border.width: root.isEditing ? root.labelBorderWidth : Theme.borders.b0

            Text {
                id: text
                anchors.centerIn: parent
                text: root.labelText
                font.pixelSize: Theme.typography.fontSize150
                color: root.labelTextColor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.Wrap
            }
        }
    }

    // Prevent tap propagating below
    TapHandler { gesturePolicy: TapHandler.ReleaseWithinBounds }

    TapHandler {
        enabled: root.tapEnabled
        acceptedButtons: Qt.LeftButton
        onTapped: root.tapped()
    }

    DragHandler {
        id: handler
        enabled: root.isEditing

        onActiveChanged: root.isDragging = active

        onTranslationChanged: {
            // Dragging a MapQuickItem updates its coordinate automatically; propagate it out.
            root.pointChanged(root.coordinate)
        }
    }
}
