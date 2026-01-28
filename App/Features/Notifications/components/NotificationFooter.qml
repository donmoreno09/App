import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App 1.0
import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.Language 1.0

ColumnLayout {
    id: root
    visible: TruckNotificationModel.count > 0 || AlertZoneNotificationModel.count > 0
    anchors.left: parent.left
    anchors.right: parent.right
    spacing: Theme.spacing.s0

    signal deleteAllRequested()

    UI.HorizontalDivider { color: Theme.colors.whiteA10 }

    Pane {
        Layout.fillWidth: true
        padding: Theme.spacing.s8
        background: Rectangle { color: Theme.colors.transparent }

        RowLayout {
            anchors.fill: parent
            spacing: Theme.spacing.s2

            UI.HorizontalSpacer {}

            UI.Button {
                Layout.preferredWidth: parent.width / 2
                variant: UI.ButtonStyles.Danger
                text: `${TranslationManager.revision}` && qsTr("Delete All")

                onClicked: {
                    root.deleteAllRequested()
                }
            }
        }
    }
}
