import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App 1.0
import App.Themes 1.0
import App.Components 1.0 as UI

ColumnLayout {
    spacing: Theme.spacing.s4

    property int areaType: AreaForm.Rectangle

    enum AreaType {
        Polygon = 3,
        // This is actually CircleType in BE
        Rectangle,
        Ellipse
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Theme.spacing.s2

        Label {
            Layout.fillWidth: true
            text: qsTr("Area Type(*)")
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
                width: parent.width
                spacing: Theme.spacing.s4

                AreaButton {
                    text: qsTr("Rectangle")
                    source: "qrc:/App/assets/icons/rectangle.svg"
                    checked: areaType === AreaForm.Rectangle
                    onClicked: areaType = AreaForm.Rectangle
                }

                AreaButton {
                    text: qsTr("Ellipse")
                    source: "qrc:/App/assets/icons/ellipse.svg"
                    checked: areaType === AreaForm.Ellipse
                    onClicked: areaType = AreaForm.Ellipse
                }

                AreaButton {
                    text: qsTr("Polygon")
                    source: "qrc:/App/assets/icons/polygon.svg"
                    checked: areaType === AreaForm.Polygon
                    onClicked: areaType = AreaForm.Polygon
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
        Layout.fillWidth: true
        source: {
            switch (areaType) {
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
