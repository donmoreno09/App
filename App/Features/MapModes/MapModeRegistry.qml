pragma Singleton

import QtQuick 6.8
import App.Features.MapModes 1.0

QtObject {
    property InteractionMode interactionMode: null

    // Point
    property CreatePointMode createPointMode: null
    property EditPointMode editPointMode: null

    // Rectangle
    property CreateRectangleMode createRectangleMode: null
    property EditRectangleMode editRectangleMode: null

    // Ellipse
    property CreateEllipseMode createEllipseMode: null
    property EditEllipseMode editEllipseMode: null

    // Polygon
    property CreatePolygonMode createPolygonMode: null
    property EditPolygonMode editPolygonMode: null
}
