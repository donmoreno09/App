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

    // The map instance used for coordinate conversions. Must be provided by callers.
    property var mapItem: null

    property bool isDragging: false

    signal tapped()
    signal pointChanged(geoCoordinate coord)

    // Scratch state for move drag
    property geoCoordinate _startCoord: QtPositioning.coordinate()
    property geoCoordinate _anchorCoord: QtPositioning.coordinate()
    property point _lastScenePos: Qt.point(0, 0)

    function _translateCoord(startCoord, anchorCoord, pointerCoord) {
        if (!startCoord || !startCoord.isValid
                || !anchorCoord || !anchorCoord.isValid
                || !pointerCoord || !pointerCoord.isValid) {
            return QtPositioning.coordinate()
        }

        let dLat = pointerCoord.latitude - anchorCoord.latitude
        let dLon = pointerCoord.longitude - anchorCoord.longitude
        if (dLon > 180)
            dLon -= 360
        else if (dLon < -180)
            dLon += 360

        const nextLat = Math.max(-90, Math.min(90, startCoord.latitude + dLat))
        let nextLon = startCoord.longitude + dLon
        while (nextLon > 180)
            nextLon -= 360
        while (nextLon <= -180)
            nextLon += 360

        return QtPositioning.coordinate(nextLat, nextLon)
    }

    anchorPoint.x: icon.x + (icon.width / 2)
    anchorPoint.y: icon.y + (icon.height / 2)

    sourceItem: Item {
        id: marker
        width: Math.max(icon.width, labelBox.visible ? labelBox.width : 0)
        height: icon.height + (labelBox.visible ? Theme.spacing.s1 + labelBox.height : 0)

        Image {
            id: icon
            width: root.iconWidth
            height: root.iconHeight
            x: (marker.width - width) / 2
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
            x: (marker.width - width) / 2
            y: icon.height + Theme.spacing.s1
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
        target: null
        enabled: root.isEditing
        acceptedButtons: Qt.LeftButton
        minimumPointCount: 1
        maximumPointCount: 1
        cursorShape: Qt.SizeAllCursor

        onActiveChanged: {
            root.isDragging = active

            const map = root.mapItem
            if (active) {
                if (!map)
                    return

                root._startCoord = root.coordinate

                const pressScene = handler.centroid.scenePressPosition
                root._lastScenePos = pressScene

                const pressPx = map.mapFromItem(null, pressScene.x, pressScene.y)
                root._anchorCoord = map.toCoordinate(pressPx, false)
            } else {
                root._startCoord = QtPositioning.coordinate()
                root._anchorCoord = QtPositioning.coordinate()
            }
        }

        onActiveTranslationChanged: {
            const map = root.mapItem
            if (!map || !active || !root._startCoord.isValid || !root._anchorCoord.isValid)
                return

            const scenePos = centroid.scenePosition
            if (scenePos.x === root._lastScenePos.x &&
                    scenePos.y === root._lastScenePos.y) {
                return
            }

            root._lastScenePos = scenePos

            const pointerPx = map.mapFromItem(null, scenePos.x, scenePos.y)
            const pointerCoord = map.toCoordinate(pointerPx, false)
            if (!pointerCoord.isValid)
                return

            const nextCoord = root._translateCoord(root._startCoord, root._anchorCoord, pointerCoord)
            if (!nextCoord.isValid)
                return

            root.pointChanged(nextCoord)
        }
    }
}
