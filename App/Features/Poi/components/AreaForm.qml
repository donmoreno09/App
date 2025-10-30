import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App 1.0
import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.MapModes 1.0

ColumnLayout {
    spacing: Theme.spacing.s4

    property int areaType: AreaForm.Point

    readonly property bool isValid: formLoader.item && formLoader.item.validate()
    readonly property bool isEditing: !!MapModeController.poi

    Connections {
        target: MapModeController

        function onPoiChanged() {
            areaButtons.updateButtons()
        }
    }

    enum AreaType {
        // Mirror backend's values
        Point = 1,
        Polygon = 3,
        Rectangle, // There's no RectangleType from the backend, see isRectangle below.
        Ellipse
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Theme.spacing.s2

        Label {
            Layout.fillWidth: true
            text: qsTr("Shape Type(*)")
            leftPadding: Theme.spacing.s4
            rightPadding: Theme.spacing.s4
            font {
                family: Theme.typography.bodySans25Family
                pointSize: Theme.typography.bodySans25Size
                weight: Theme.typography.bodySans25Weight
            }
        }

        Pane {
            Layout.fillWidth: true

            RowLayout {
                id: areaButtons
                width: parent.width
                spacing: Theme.spacing.s4

                function updateButtons() {
                    if (!MapModeController.poi) return

                    areaType = (MapModeController.poi.isRectangle) ? AreaForm.Rectangle :  MapModeController.poi.shapeTypeId
                }

                Component.onCompleted: updateButtons()

                AreaButton {
                    text: qsTr("Point")
                    source: "qrc:/App/assets/icons/point.svg"
                    checked: areaType === AreaForm.Point
                    enabled: !isEditing || areaType === AreaForm.Point
                    onClicked: if (!isEditing) {
                        areaType = AreaForm.Point
                        MapModeController.setActiveMode(MapModeRegistry.createPointMode)
                    }
                }

                AreaButton {
                    text: qsTr("Rectangle")
                    source: "qrc:/App/assets/icons/rectangle.svg"
                    checked: areaType === AreaForm.Rectangle
                    enabled: !isEditing || areaType === AreaForm.Rectangle
                    onClicked: if (!isEditing) {
                        areaType = AreaForm.Rectangle
                        MapModeController.setActiveMode(MapModeRegistry.createRectangleMode)
                    }
                }

                AreaButton {
                    text: qsTr("Ellipse")
                    source: "qrc:/App/assets/icons/ellipse.svg"
                    checked: areaType === AreaForm.Ellipse
                    enabled: !isEditing || areaType === AreaForm.Ellipse
                    onClicked: if (!isEditing) {
                        areaType = AreaForm.Ellipse
                        MapModeController.setActiveMode(MapModeRegistry.createEllipseMode)
                    }
                }

                AreaButton {
                    text: qsTr("Polygon")
                    source: "qrc:/App/assets/icons/polygon.svg"
                    checked: areaType === AreaForm.Polygon
                    enabled: !isEditing || areaType === AreaForm.Polygon
                    onClicked: if (!isEditing) {
                        areaType = AreaForm.Polygon
                        MapModeController.setActiveMode(MapModeRegistry.createPolygonMode)
                    }
                }
            }

            background: Rectangle {
                color: Theme.colors.transparent
                border.width: 1
                border.color: Theme.colors.whiteA40
                radius: Theme.radius.md
            }
        }
    }

    Loader {
        id: formLoader
        Layout.fillWidth: true
        source: {
            switch (areaType) {
            case AreaForm.Point:
                return "PointForm.qml"
            case AreaForm.Rectangle:
                return "RectangleForm.qml"
            case AreaForm.Ellipse:
                return "EllipseForm.qml"
            case AreaForm.Polygon:
                return "PolygonForm.qml"
            default:
                console.error("Invalid areaType value in AreaForm")
            }
        }
    }
}
