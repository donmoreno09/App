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

function maxCheckNaN(a, b) {
    if (isNaN(a)) return b
    if (isNaN(b)) return a
    return Math.max(a, b)
}

function minCheckNaN(a, b) {
    if (isNaN(a)) return b
    if (isNaN(b)) return a
    return Math.min(a, b)
}

function normalizeCorners(tl, br, QtPositioning) {
    if (!tl || !br)
        return { topLeft: tl, bottomRight: br }

    const n = maxCheckNaN(tl.latitude, br.latitude)
    const s = minCheckNaN(tl.latitude, br.latitude)
    const w = minCheckNaN(tl.longitude, br.longitude)
    const e = maxCheckNaN(tl.longitude, br.longitude)

    return {
        topLeft: QtPositioning.coordinate(n, w),
        bottomRight: QtPositioning.coordinate(s, e),
    }
}

// kind: 0 TL, 1 TR, 2 BR, 3 BL
function applyHandleMove(kind, coord, tl, br, QtPositioning) {
    let nextTL = tl
    let nextBR = br

    if (kind === 0) {
        nextTL = coord
    } else if (kind === 1) {
        nextTL = QtPositioning.coordinate(coord.latitude, tl.longitude)
        nextBR = QtPositioning.coordinate(br.latitude, coord.longitude)
    } else if (kind === 2) {
        nextBR = coord
    } else { // 3
        nextBR = QtPositioning.coordinate(coord.latitude, br.longitude)
        nextTL = QtPositioning.coordinate(tl.latitude, coord.longitude)
    }

    const normalized = normalizeCorners(nextTL, nextBR, QtPositioning)
    return {
        topLeft: normalized.topLeft,
        bottomRight: normalized.bottomRight,
    }
}
