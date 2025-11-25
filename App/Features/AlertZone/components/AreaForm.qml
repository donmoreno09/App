import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App 1.0
import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.MapModes 1.0
import App.Features.Language 1.0

ColumnLayout {
    spacing: Theme.spacing.s4

    property int areaType: AreaForm.Polygon

    readonly property bool isValid: formLoader.item && formLoader.item.validate()
    readonly property bool isEditing: !!MapModeController.alertZone

    Connections {
        target: MapModeController

        function onAlertZoneChanged() {
            areaButtons.updateButtons()
        }
    }

    enum AreaType {
        Polygon = 3,
        Rectangle, // There's no RectangleType from the backend, see isRectangle below.
        Ellipse
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Theme.spacing.s2

        Pane {
            Layout.fillWidth: true

            RowLayout {
                id: areaButtons
                width: parent.width
                spacing: Theme.spacing.s4

                function updateButtons() {
                    if (!MapModeController.alertZone) return

                    areaType = (MapModeController.alertZone.isRectangle) ? AreaForm.Rectangle :  MapModeController.alertZone.shapeTypeId
                }

                Component.onCompleted: updateButtons()

                AreaButton {
                    text: `${TranslationManager.revision}` && qsTr("Polygon")
                    source: "qrc:/App/assets/icons/polygon.svg"
                    checked: areaType === AreaForm.Polygon
                    enabled: !isEditing || areaType === AreaForm.Polygon
                    onClicked: if (!isEditing) {
                        areaType = AreaForm.Polygon
                        MapModeController.setActiveMode(MapModeRegistry.createPolygonMode)
                    }
                }

                AreaButton {
                    text: `${TranslationManager.revision}` && qsTr("Rectangle")
                    source: "qrc:/App/assets/icons/rectangle.svg"
                    checked: areaType === AreaForm.Rectangle
                    enabled: !isEditing || areaType === AreaForm.Rectangle
                    onClicked: if (!isEditing) {
                        areaType = AreaForm.Rectangle
                        MapModeController.setActiveMode(MapModeRegistry.createRectangleMode)
                    }
                }

                AreaButton {
                    text: `${TranslationManager.revision}` && qsTr("Ellipse")
                    source: "qrc:/App/assets/icons/ellipse.svg"
                    checked: areaType === AreaForm.Ellipse
                    enabled: !isEditing || areaType === AreaForm.Ellipse
                    onClicked: if (!isEditing) {
                        areaType = AreaForm.Ellipse
                        MapModeController.setActiveMode(MapModeRegistry.createEllipseMode)
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
            case AreaForm.Rectangle:
                return "AlertZoneRectangleForm.qml"
            case AreaForm.Ellipse:
                return "AlertZoneEllipseForm.qml"
            case AreaForm.Polygon:
                return "AlertZonePolygonForm.qml"
            default:
                console.error("Invalid areaType value in AreaForm")
            }
        }
    }
}
