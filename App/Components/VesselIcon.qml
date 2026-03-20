import QtQuick 6.8

import App.Themes 1.0
import App.Features.Map 1.0

Item {
    id: root

    required property int    domain
    property  int            severity:      TrackIcon.Neutral
    property  int            motion:        TrackIcon.Moving
    required property int    ui
    required property real   heading
    property  string         labelText:     ""
    property  real           baseRotationDeg: 0

    signal tapped()
    signal hoverChanged(bool hovered)
    readonly property alias hovered: trackIcon.hovered

    required property double displayHeading
    required property int    a
    required property int    b
    required property int    c
    required property int    d
    required property int    shipLength
    required property int    shipWidth
    required property bool   hasDimensions


    readonly property real zoomLevel: MapController.map ? MapController.map.zoomLevel : 8

    readonly property real pinSize: Math.max(48 - (zoomLevel - 8) * 5, 30)

    readonly property real zoomScale: Math.pow(2, zoomLevel - 10)

    readonly property real rawPxLength: hasDimensions ? Math.min(shipLength, 500) * zoomScale / 7 : 0
    readonly property real rawPxWidth:  hasDimensions ? Math.min(shipWidth,  80)  * zoomScale / 7 : 0

    readonly property real zf:          Math.max(zoomLevel - 10, 0)
    readonly property real minPxLength: 4 + zf * 2
    readonly property real minPxWidth:  2 + zf * 0.8

    readonly property real pxLength: Math.min(Math.max(rawPxLength, minPxLength), 300)
    readonly property real pxWidth:  Math.min(Math.max(rawPxWidth,  minPxWidth),  60)

    readonly property real antX: hasDimensions ? pxWidth  * (c / shipWidth)  : pxWidth  / 2
    readonly property real antY: hasDimensions ? pxLength * (a / shipLength) : pxLength / 2

    readonly property real halfDiag: Math.ceil(Math.max(Math.sqrt(pxLength * pxLength + pxWidth * pxWidth), pinSize / 2 + 2))

    readonly property real midOffX: pxWidth  / 2 - antX
    readonly property real midOffY: pxLength / 2 - antY

    readonly property real headingRad: (displayHeading + 44) * Math.PI / 180

    readonly property real shipCenterX: halfDiag + midOffX * Math.cos(headingRad) - midOffY * Math.sin(headingRad)
    readonly property real shipCenterY: halfDiag + midOffX * Math.sin(headingRad) + midOffY * Math.cos(headingRad)

    width:  halfDiag * 2
    height: halfDiag * 2

    Image {
        id: shipShape
        x:      root.halfDiag - root.antX
        y:      root.halfDiag - root.antY
        width:  root.pxWidth
        height: root.pxLength
        source: "qrc:/App/assets/vessels/ship-shape.svg"
        fillMode: Image.PreserveAspectFit
        smooth: true
        transform: Rotation {
            angle:    root.displayHeading + 44
            origin.x: root.antX
            origin.y: root.antY
        }
    }

    TrackIcon {
        id: trackIcon
        x:      root.shipCenterX - root.pinSize / 2
        y:      root.shipCenterY - root.pinSize / 2
        z: 1
        width:  root.pinSize
        height: root.pinSize

        domain:           root.domain
        severity:         root.severity
        motion:           root.motion
        ui:               root.ui
        heading:          root.heading
        labelText:        root.labelText
        baseRotationDeg:  root.baseRotationDeg

        onTapped:        root.tapped()
        onHoverChanged:  root.hoverChanged(hovered)
    }
}
