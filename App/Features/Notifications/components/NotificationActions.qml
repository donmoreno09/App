import QtQuick 6.8
import QtQuick.Layouts 6.8
import QtPositioning 6.8

import App 1.0
import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.Language 1.0
import App.Features.Map 1.0
import App.Features.Notifications 1.0

RowLayout {
    id: root

    required property string notificationId
    required property var location

    Layout.fillWidth: true
    spacing: Theme.spacing.s2

    UI.HorizontalSpacer {}

    UI.Button {
        text: `${TranslationManager.revision}` && qsTr("View on Map")
        variant: UI.ButtonStyles.Primary
        icon.source: "qrc:/App/assets/icons/icona_centra_clean.svg"
        icon.width: 16
        icon.height: 16
        Layout.preferredHeight: Theme.spacing.s8
        enabled: location && location.isValid

        onClicked: {
            MapController.setMapCenter(location)
        }
    }

    UI.Button {
        text: `${TranslationManager.revision}` && qsTr("Delete")
        variant: UI.ButtonStyles.Ghost
        Layout.preferredHeight: Theme.spacing.s8

        onClicked: {
            TruckNotificationModel.removeNotification(notificationId)
        }
    }
}
