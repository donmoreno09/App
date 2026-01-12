import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8

import App.Themes 1.0
import App.Features.Map 1.0

import "../.."
import "./PolygonGeometry.js" as PolyGeom
import App.Components 1.0 as UI

PolygonMode {
    id: root
    type: "creating"
    z: Theme.elevation.z100 + 100

    ListModel { id: coordinatesModel }
    property bool closed: false
    readonly property bool isDraggingHandle: committedPolygon.isDraggingHandle
    property var polygonPath: []

    function coordinatesCount() {
        return coordinatesModel.count
    }

    function getCoordinate(index) {
        return coordinatesModel.get(index)
    }

    function setCoordinate(index, coord) {
        if (index < 0 || index >= coordinatesModel.count) return

        coordinatesModel.set(index, coord)
        _syncPathFromModel()
    }

    function buildGeometry() {
        const coords = PolyGeom.pathToCoordinates(polygonPath)
        if (coords.length < 4) return {}

        return {
            shapeTypeId: MapModeController.PolygonType,
            coordinates: coords
        }
    }

    function resetPreview() {
        coordinatesModel.clear()
        polygonPath = []
        closed = false
        root.coordinatesChanged()
    }

    function _syncPathFromModel() {
        polygonPath = PolyGeom.modelToPath(coordinatesModel, QtPositioning)
    }

    function _addCoordinate(coord) {
        coordinatesModel.append(coord)
        _syncPathFromModel()
    }

    function _tryClose() {
        if (closed || coordinatesModel.count < 3) return

        closed = true
        root.coordinatesChanged()
    }

    TapHandler {
        id: addTap
        acceptedButtons: Qt.LeftButton
        gesturePolicy: TapHandler.ReleaseWithinBounds
        enabled: !committedPolygon.isBodyPressed && !root.isDraggingHandle && !committedPolygon.isMovingPolygon

        onTapped: function(event) {
            if (closed) {
                root.resetPreview()
            }

            const point = MapController.map.mapFromItem(root, event.position)
            const coord = MapController.map.toCoordinate(point, false)
            if (coord.isValid) _addCoordinate(coord)
            if (event.tapCount >= 2) _tryClose()
        }
    }

    UI.EditablePolygon {
        id: committedPolygon
        visible: root.polygonPath.length > 0
        z: root.z + 1

        isEditing: true
        closed: root.closed
        map: MapController.map
        path: root.polygonPath
        handleModel: coordinatesModel

        tapEnabled: false
        showLabel: false
        fillColor: "#22448888"
        strokeColor: "green"
        highlightColor: "white"
        previewStrokeColor: "orange"

        onPathEdited: function(nextPath) {
            PolyGeom.applyPathToModel(coordinatesModel, nextPath, QtPositioning)
            polygonPath = PolyGeom.clonePath(nextPath, QtPositioning)
            root.coordinatesChanged()
        }

        onFirstPointTapped: root._tryClose()
    }
}
