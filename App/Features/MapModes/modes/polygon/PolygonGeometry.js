.pragma library

function clampLat(v) {
    return Math.max(-90, Math.min(90, v))
}

function normLon(v) {
    // Wrap to [0, 360)
    const wrapped = ((v + 180) % 360 + 360) % 360
    // Shift to [-180, 180)
    return wrapped - 180
}

function asCoordinate(value, QtPositioning) {
    if (!value)
        return QtPositioning.coordinate()

    if (value.latitude !== undefined && value.longitude !== undefined)
        return QtPositioning.coordinate(Number(value.latitude), Number(value.longitude))

    if (value.x !== undefined && value.y !== undefined)
        return QtPositioning.coordinate(Number(value.y), Number(value.x))

    return QtPositioning.coordinate()
}

function clonePath(path, QtPositioning) {
    if (!path || path.length === undefined)
        return []

    const out = []
    for (let i = 0; i < path.length; ++i) {
        out.push(asCoordinate(path[i], QtPositioning))
    }
    return out
}

function modelToPath(coordinatesModel) {
    const path = []
    for (let i = 0; i < coordinatesModel.count; i++)
        path.push(coordinatesModel.get(i))
    return path
}

function applyPathToModel(model, path, QtPositioning) {
    if (!model || !path)
        return

    while (model.count > path.length)
        model.remove(model.count - 1)

    for (let i = 0; i < path.length; ++i) {
        const coord = asCoordinate(path[i], QtPositioning)
        if (i < model.count)
            model.set(i, coord)
        else
            model.append(coord)
    }
}

function pathToCoordinates(path) {
    if (!path || path.length < 3)
        return []

    const coords = []
    for (let i = 0; i < path.length; ++i) {
        const c = path[i]
        if (c && c.latitude !== undefined && c.longitude !== undefined)
            coords.push({ x: c.longitude, y: c.latitude })
    }
    if (coords.length > 0)
        coords.push({ x: coords[0].x, y: coords[0].y })

    return coords
}

function translateByDelta(startCoords, dx, dy, map, QtPositioning) {
    if (!map || !startCoords || startCoords.length === 0)
        return []

    const out = []
    for (let i = 0; i < startCoords.length; ++i) {
        const startCoord = startCoords[i]
        if (!startCoord || !startCoord.isValid) {
            out.push(asCoordinate(startCoord, QtPositioning))
            continue
        }

        const startPx = map.fromCoordinate(startCoord, false)
        if (!startPx) {
            out.push(startCoord)
            continue
        }

        const point = Qt.point(startPx.x + dx, startPx.y + dy)
        const coord = map.toCoordinate(point, false)
        out.push(coord && coord.isValid ? coord : startCoord)
    }

    return out
}

function hasPolygon(path) {
    return path && path.length >= 3
}

function calculateMidpoint(c1, c2, QtPositioning) {
    // Input validation
    if (!c1 || !c1.isValid || !c2 || !c2.isValid)
        return QtPositioning.coordinate()

    // Calculate longitude delta with dateline wrapping
    let dLon = c2.longitude - c1.longitude

    // Handle dateline wrapping
    if (dLon > 180)
        dLon -= 360
    else if (dLon < -180)
        dLon += 360

    // Latitude: simple average
    const midLat = (c1.latitude + c2.latitude) / 2

    // Longitude: average with wrapping correction
    const midLon = normLon(c1.longitude + dLon / 2)

    return QtPositioning.coordinate(clampLat(midLat), midLon)
}
