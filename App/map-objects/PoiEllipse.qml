// PoiEllipse.qml
import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8

import App 1.0
import App.Themes 1.0
import App.Features.Map 1.0
import App.Features.MapModes 1.0
import App.Components 1.0 as UI

UI.EditableEllipse {
    id: root
    z: Theme.elevation.z100 + (isEditing ? 100 : 0)
    isEditing: MapModeController.poi && id === MapModeController.poi.id
    map: MapController.map
    center: model.coordinate
    radiusA: model.radiusA
    radiusB: model.radiusB
    fillColor: "#22448888"
    strokeColor: "green"
    highlightColor: "white"
    tapEnabled: !root.isEditing && !MapModeController.isCreating
    onTapped: MapModeController.editPoi(PoiModel.getEditablePoi(index))
    labelText: label
    labelFillColor: Theme.colors.hexWithAlpha("#539E07", 0.6)
    labelBorderColor: Theme.colors.white
    labelTextColor: Theme.colors.white
    labelBorderWidth: Theme.borders.b1

    onEllipseChanged: function(c, a, b) {
        // Batch the internal geometry update
        updateGeometry(c, a, b)

        // Update model (this is fast, just property assignments)
        model.coordinate = c
        model.radiusA = a
        model.radiusB = b

        // Only emit signals when NOT actively dragging
        if (!isMovingEllipse && !isDraggingHandler) {
            MapModeRegistry.editEllipseMode.coordChanged()
            MapModeRegistry.editEllipseMode.majorAxisChanged()
            MapModeRegistry.editEllipseMode.minorAxisChanged()
        }
    }

    // Emit signals when drag/handle manipulation ends
    onIsMovingEllipseChanged: {
        if (!isMovingEllipse) {
            MapModeRegistry.editEllipseMode.coordChanged()
        }
    }

    onIsDraggingHandlerChanged: {
        if (!isDraggingHandler) {
            MapModeRegistry.editEllipseMode.majorAxisChanged()
            MapModeRegistry.editEllipseMode.minorAxisChanged()
        }
    }
}
