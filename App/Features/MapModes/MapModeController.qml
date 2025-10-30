pragma Singleton

import QtQuick 6.8

import App 1.0
import App.Features.MapModes 1.0
import App.Features.SidePanel 1.0

import "qrc:/App/Features/SidePanel/routes.js" as Routes

QtObject {
    id: root

    // Properties
    property var poi: null
    readonly property bool isCreating: activeMode && activeMode.type === "creating"
    readonly property bool isEditing: poi != null

    property bool isSwitchingToOtherPoi: false

    property BaseMode activeMode: null

    enum ShapeType {
        PointType = 1,
        LineStringType,
        PolygonType, // For RectangleType, check if PolygonType and use poi's isRectangle property
        CircleType,  // This type is unused.
        EllipseType
    }

    // Methods
    function setActiveMode(mode: BaseMode) {
        if (poi && !isSwitchingToOtherPoi) {
            poi = null
            PoiModel.discardChanges()
        }

        if (isSwitchingToOtherPoi) isSwitchingToOtherPoi = false

        if (activeMode && activeMode.resetPreview) {
            activeMode.resetPreview()
        }

        activeMode = mode
    }

    function editPoi(editablePoi) {
        if (poi) isSwitchingToOtherPoi = true

        poi = editablePoi
        switch (poi.shapeTypeId) {
        case MapModeController.PointType:
            activeMode = MapModeRegistry.editPointMode
            break;
        case MapModeController.EllipseType:
            activeMode = MapModeRegistry.editEllipseMode
            break;
        case MapModeController.PolygonType:
            if (poi.isRectangle) activeMode = MapModeRegistry.editRectangleMode
            else activeMode = MapModeRegistry.editPolygonMode
            break;
        default:
            console.error("Editing PoI with unknown shape type")
        }
        SidePanelController.openOrRefresh(Routes.Poi)
    }
}
