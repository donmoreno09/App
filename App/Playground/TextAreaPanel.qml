import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.Panels 1.0
import App.Features.Language 1.0

PanelTemplate {
    title.text: `${TranslationManager.revision}` && qsTr("TextArea Test")

    ScrollView {
        id: sv
        anchors.fill: parent

        Frame {
            padding: Theme.spacing.s4
            width: sv.availableWidth

            ColumnLayout {
                anchors.fill: parent
                spacing: Theme.spacing.s4

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    Layout.fillHeight: true
                    spacing: Theme.spacing.s4

                    UI.TextArea {
                        Layout.fillWidth: true
                        variant: UI.InputStyles.Default
                        labelText: "Label()"
                        tooltipText: "This is a tooltip"
                        placeholderText: "Placeholder text..."
                        messageText: "Message goes here"
                    }
                    UI.TextArea {
                        Layout.fillWidth: true
                        variant: UI.InputStyles.Error
                        labelText: "Label()"
                        tooltipText: "Error tooltip"
                        placeholderText: "Placeholder text..."
                        messageText: "Message goes here"
                    }
                    UI.TextArea {
                        Layout.fillWidth: true
                        variant: UI.InputStyles.Warning
                        labelText: "Label()"
                        tooltipText: "Warning tooltip"
                        placeholderText: "Placeholder text..."
                        messageText: "Message goes here"
                    }
                    UI.TextArea {
                        Layout.fillWidth: true
                        variant: UI.InputStyles.Success
                        labelText: "Label()"
                        tooltipText: "Success tooltip"
                        placeholderText: "Placeholder text..."
                        messageText: "Message goes here"
                    }
                    UI.TextArea {
                        Layout.fillWidth: true
                        variant: UI.InputStyles.Default
                        enabled: false
                        labelText: "Label(*)"
                        tooltipText: "Disabled tooltip"
                        placeholderText: "Placeholder text..."
                        messageText: "Message goes here"
                    }
                }
            }
        }
    }
}
