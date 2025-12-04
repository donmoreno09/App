import QtQuick 6.8
import QtQuick.Layouts 6.8

import App 1.0
import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.Language 1.0

RowLayout {
    id: root

    signal deleteAllRequested()

    visible: TruckNotificationModel.count > 0 || AlertZoneNotificationModel.count > 0
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
