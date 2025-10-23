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
    // TODO: Handle discarding changes by containing the "old" poi
    //       For now, I'm using PoiModel.discardChanges().

    property BaseMode activeMode: null

    enum ShapeType {
        PointType = 1,
        LineStringType,
        PolygonType,
        CircleType,
        EllipseType
    }

    // Methods
    function setActiveMode(mode: BaseMode) {
        // TODO: Handle discarding changes
        if (poi) {
            poi = null
            PoiModel.discardChanges()
        }

        activeMode = mode
    }

    function editPoi(editablePoi) {
        PoiModel.discardChanges()
        poi = editablePoi
        switch (poi.shapeTypeId) {
        case MapModeController.PointType:
            activeMode = MapModeRegistry.editPointMode
            break;
        default:
            console.error("Editing PoI with unknown shape type")
        }
        SidePanelController.openOrRefresh(Routes.Poi)
    }
}
