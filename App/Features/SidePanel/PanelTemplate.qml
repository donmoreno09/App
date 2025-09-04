import QtQuick 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.SidePanel 1.0

BasePanel {
    property alias title: title

    header: ColumnLayout {
        width: parent.width
        height: Theme.layout.panelTitleHeight

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Theme.spacing.s4

            UI.HorizontalPadding { }

            // Title
            Text {
                id: title
                color: Theme.colors.primaryText
                font.family: Theme.typography.familySans
                font.pixelSize: Theme.typography.sizeXl
                font.weight: Theme.typography.weightSemibold
                Layout.fillWidth: true
            }

            // Close Button
            UI.Button {
                Layout.preferredWidth: Theme.spacing.s8
                Layout.preferredHeight: Theme.spacing.s8
                variant: "ghost"
                backgroundRect.radius: Theme.radius.circle(width, height)
                backgroundRect.border.width: Theme.borders.b0

                // Close icon
                Text {
                    anchors.centerIn: parent
                    text: "✕"
                    color: Theme.colors.primaryText
                    font.pixelSize: Theme.typography.sizeLg
                }

                onClicked: SidePanelController.close()
            }

            UI.HorizontalPadding { }
        }

        UI.HorizontalDivider { }
    }
}
