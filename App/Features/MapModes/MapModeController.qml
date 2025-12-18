pragma Singleton

import QtQuick 6.8

import App 1.0
import App.Features.SidePanel 1.0

import "modes"
import "qrc:/App/Features/SidePanel/routes.js" as Routes

QtObject {
    id: root

    // Properties
    property var poi: null
    property var alertZone: null
    readonly property bool isCreating: activeMode && activeMode.type === "creating"
    readonly property bool isEditing: poi != null || alertZone != null
    property bool _willEdit: false

    property BaseMode activeMode: null

    enum ShapeType {
        PointType = 1,
        LineStringType,
        PolygonType, // For RectangleType, check if PolygonType and use poi's isRectangle property
        CircleType,  // This type is unused.
        EllipseType
    }

    // Methods
    function clearState() {
        if (poi) PoiModel.discardChanges()
        poi = null
        if (alertZone) AlertZoneModel.discardChanges()
        alertZone = null
    }

    function setActiveMode(mode: BaseMode) {
        if (!_willEdit) clearState()
        _willEdit = false

        if (activeMode && activeMode.resetPreview) {
            activeMode.resetPreview()
        }

        activeMode = mode
    }

    function editPoi(editablePoi) {
        clearState()
        _willEdit = true

        poi = editablePoi
        switch (poi.shapeTypeId) {
        case MapModeController.PointType:
            setActiveMode(MapModeRegistry.editPointMode)
            break;
        case MapModeController.EllipseType:
            setActiveMode(MapModeRegistry.editEllipseMode)
            break;
        case MapModeController.PolygonType:
            if (poi.isRectangle) setActiveMode(MapModeRegistry.editRectangleMode)
            else setActiveMode(MapModeRegistry.editPolygonMode)
            break;
        default:
            console.error("Editing PoI with unknown shape type")
        }
        SidePanelController.openOrRefresh(Routes.Poi)
    }

    function editAlertZone(editableAlertZone) {
        clearState()
        _willEdit = true

        alertZone = editableAlertZone
        switch (alertZone.shapeTypeId) {
        case MapModeController.EllipseType:
            setActiveMode(MapModeRegistry.editEllipseMode)
            break;
        case MapModeController.PolygonType:
            if (alertZone.isRectangle) setActiveMode(MapModeRegistry.editRectangleMode)
            else setActiveMode(MapModeRegistry.editPolygonMode)
            break;
        default:
            console.error("Editing Alert Zone with unknown shape type")
        }
        SidePanelController.openOrRefresh(Routes.AlertZone)
    }
}
