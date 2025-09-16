import QtQuick 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.SidePanel 1.0
import App.Features.Language 1.0

PanelTemplate {
    title.text: qsTr("Notifications")

    ColumnLayout {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Theme.spacing.s4

        spacing: Theme.spacing.s4

        UI.Button {
            Layout.fillWidth: true
            variant: "danger"
            text: (TranslationManager.revision, qsTr("Generate Urgent Notification"))

            onClicked: NotificationsController.urgent.push({ message: "Urgent!" })
        }

        UI.Button {
            Layout.fillWidth: true
            variant: "warning"
            text: (TranslationManager.revision, qsTr("Generate Warning Notification"))

            onClicked: NotificationsController.warning.push({ message: "Warning!" })
        }

        UI.Button {
            Layout.fillWidth: true
            variant: "primary"
            text: (TranslationManager.revision, qsTr("Generate Info Notification"))

            onClicked: NotificationsController.info.push({ message: "Info!" })
        }
    }
}
