import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI

Rectangle {
    property alias text: label.text
    property alias toggle: toggle

    implicitHeight: container.height
    color: Theme.colors.whiteA2

    Pane {
        id: container
        width: parent.width
        padding:  Theme.spacing.s3
        background: Rectangle { color: Theme.colors.transparent }

        RowLayout {
            width: parent.width

            Label {
                id: label
                font {
                    family: Theme.typography.bodySans25Family
                    pointSize: Theme.typography.bodySans25Size
                    weight: Theme.typography.bodySans25Weight
                }
            }

            UI.HorizontalSpacer { }

            UI.Toggle { id: toggle }
        }
    }

    // Bottom border
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: Theme.borders.b2
        color: Theme.colors.border
    }
}
