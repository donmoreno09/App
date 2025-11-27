import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0

Rectangle {
    id: root

    property alias text: label.text
    property alias source: image.source
    property bool selected: false

    signal clicked()

    Layout.fillWidth: true
    implicitHeight: container.height

    color: Theme.colors.transparent
    border.width: Theme.borders.b2
    border.color: selected ? Theme.colors.border : Theme.colors.transparent

    Pane {
        id: container
        width: parent.width
        padding: Theme.spacing.s4
        background: Rectangle { color: Theme.colors.transparent }

        ColumnLayout {
            width: parent.width
            spacing: Theme.spacing.s2

            TapHandler {
                target: root
                acceptedButtons: Qt.LeftButton
                gesturePolicy: TapHandler.ReleaseWithinBounds
                onTapped: root.clicked()
            }

            Image {
                id: image
                Layout.fillWidth: true
                Layout.preferredHeight: width
                fillMode: Image.PreserveAspectFit
            }

            Text {
                id: label
                Layout.fillWidth: true
                color: "white"
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                font {
                    family: Theme.typography.bodySans15Family
                    pointSize: Theme.typography.bodySans15Size
                    weight: Theme.typography.bodySans15Weight
                }
            }
        }
    }
}
