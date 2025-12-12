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

function lonDelta(a, b) {
    let d = b - a
    while (d > 180) d -= 360
    while (d < -180) d += 360
    return Math.abs(d)
}

function hasEllipse(center, radiusA, radiusB) {
    return center && center.isValid && radiusA > 0 && radiusB > 0
}

function ellipsePath(center, radiusA, radiusB, QtPositioning, segments = 96) {
    if (!hasEllipse(center, radiusA, radiusB))
        return []

    const arr = []
    const la0 = center.latitude
    const lo0 = center.longitude
    for (let i = 0; i <= segments; ++i) {
        const t = (i / segments) * Math.PI * 2
        const la = clampLat(la0 + radiusB * Math.sin(t))   // latitude uses B
        const lo = normLon(lo0 + radiusA * Math.cos(t))    // longitude uses A
        arr.push(QtPositioning.coordinate(la, lo))
    }
    return arr
}

function bboxToEllipse(c1, c2, QtPositioning) {
    if (!c1 || !c2 || !c1.isValid || !c2.isValid)
        return null

    const n = Math.max(c1.latitude,  c2.latitude)
    const s = Math.min(c1.latitude,  c2.latitude)
    const w = Math.min(c1.longitude, c2.longitude)
    const e = Math.max(c1.longitude, c2.longitude)
    const tl = QtPositioning.coordinate(n, w)
    const br = QtPositioning.coordinate(s, e)

    const cLat = (tl.latitude  + br.latitude ) / 2
    const cLon = (tl.longitude + br.longitude) / 2
    return {
        center: QtPositioning.coordinate(clampLat(cLat), normLon(cLon)),
        radiusA: lonDelta(tl.longitude, br.longitude) / 2,
        radiusB: Math.abs(br.latitude  - tl.latitude ) / 2,
    }
}

// kind: 0 N, 1 E, 2 S, 3 W
function applyHandleMove(kind, handleCoord, center, radiusA, radiusB) {
    if (!handleCoord || !handleCoord.isValid || !center || !center.isValid)
        return { center, radiusA, radiusB }

    let nextRadiusA = radiusA
    let nextRadiusB = radiusB

    if (kind === 0 || kind === 2) {
        nextRadiusB = Math.max(0, Math.abs(handleCoord.latitude - center.latitude))
    } else {
        nextRadiusA = Math.max(0, lonDelta(center.longitude, handleCoord.longitude))
    }

    return { center, radiusA: nextRadiusA, radiusB: nextRadiusB }
}

function translateCenter(center, anchorCoord, pointerCoord, QtPositioning) {
    if (!center || !center.isValid || !anchorCoord || !anchorCoord.isValid || !pointerCoord || !pointerCoord.isValid)
        return center

    let dLat = pointerCoord.latitude  - anchorCoord.latitude
    let dLon = pointerCoord.longitude - anchorCoord.longitude

    if (dLon > 180)
        dLon -= 360
    else if (dLon < -180)
        dLon += 360

    return QtPositioning.coordinate(
                clampLat(center.latitude  + dLat),
                normLon (center.longitude + dLon))
}
