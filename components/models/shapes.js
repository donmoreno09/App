.pragma library

/*
    Helper factory functions to explicitly define object's structure.
    Since Qt does not have a typing system, it'd be better for now
    to make use of factory pattern.
*/

const POINT_TYPE_ID = 1
const LINE_STRING_TYPE_ID = 2
const POLYGON_TYPE_ID = 3
const CIRCLE_TYPE_ID = 4
const ELLIPSE_TYPE_ID = 5

// Since they're using x and y in the backend
function createBECoordinate(latitude, longitude) {
    return ({ x: longitude, y: latitude })
}

// I'll put these helper functions here for now
function toBECoordinate(
    qtCoordinate /* QtPositioning.coordinate */
) {
    return createBECoordinate(qtCoordinate.latitude, qtCoordinate.longitude)
}

function toBECoordinates(
    qtCoordinates /* QtPositioning.coordinate[] */
) {
    return qtCoordinates.map(toBECoordinate)
}

function toQtCoordinate(
    beCoordinate /* { x: number, y: number } */,
    QtPositioning /* QtPositioning */
) {
    return QtPositioning.coordinate(beCoordinate.y, beCoordinate.x)
}

function toQtCoordinates(
    beCoordinates /* ({ x: number, y: number })[] */,
    QtPositioning /* QtPositioning */
) {
    return beCoordinates.map((coord) => toQtCoordinate(coord, QtPositioning))
}

function rectToQtCoordinates(
    rect /* { topLeft: coordinate, bottomRight: coordinate } */,
    QtPositioning /* QtPositioning */
) {
    const lat1 = rect.topLeft.latitude
    const lon1 = rect.topLeft.longitude
    const lat2 = rect.bottomRight.latitude
    const lon2 = rect.bottomRight.longitude

    return [
        QtPositioning.coordinate(lat1, lon1), // top-left
        QtPositioning.coordinate(lat1, lon2), // top-right
        QtPositioning.coordinate(lat2, lon2), // bottom-right
        QtPositioning.coordinate(lat2, lon1), // bottom-left
        QtPositioning.coordinate(lat1, lon1)  // close polygon
    ]
}

function createPoint(
    id /* string */,
    label /* string */,
    qtCoordinate /* QtPositioning.coordinate */
) {
    return ({
        id,
        label,
        geometry: {
            shapeTypeId: POINT_TYPE_ID,
            coordinate: createBECoordinate(qtCoordinate.latitude, qtCoordinate.longitude),
        },
    })
}

function createLineString(
    id /* string */,
    label /* string */,
    qtCoordinates /* QtPositioning.coordinate[] */
) {
    return ({
        id,
        label,
        geometry: {
            shapeTypeId: LINE_STRING_TYPE_ID,
            coordinates: qtCoordinates.map((coord) => createBECoordinate(coord.latitude, coord.longitude)),
        },
    })
}

function createPolygon(
    id /* string */,
    label /* string */,
    qtCoordinates /* QtPositioning.coordinate[] */
) {
    return ({
        id,
        label,
        geometry: {
            shapeTypeId: POLYGON_TYPE_ID,
            coordinates: qtCoordinates.map((coord) => createBECoordinate(coord.latitude, coord.longitude)),
        },
    })
}

function createCircle(
    id /* string */,
    label /* string */,
    qtCoordinate /* QtPositioning.coordinate */,
    radiusA /* number (corresponding to longitude) */,
    radiusB /* number (corresponding to latitude) */
) {
    return ({
        id,
        label,
        geometry: {
            shapeTypeId: CIRCLE_TYPE_ID,
            coordinate: createBECoordinate(qtCoordinate.latitude, qtCoordinate.longitude),
            radiusA,
            radiusB,
        },
    })
}

function createEllipse(
    id /* string */,
    label /* string */,
    qtCoordinate /* QtPositioning.coordinate */,
    radiusA /* number (corresponding to latitude) */,
    radiusB /* number (corresponding to longitude) */
) {
    return ({
        id,
        label,
        geometry: {
            shapeTypeId: ELLIPSE_TYPE_ID,
            coordinate: createBECoordinate(qtCoordinate.latitude, qtCoordinate.longitude),
            radiusA,
            radiusB,
        },
    })
}
