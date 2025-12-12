pragma Singleton

import QtQuick 6.8

import "modes"
import "modes/ellipse"
import "modes/point"
import "modes/polygon"
import "modes/rectangle"

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
