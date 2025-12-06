import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.Panels 1.0
import App.Features.Language 1.0

PanelTemplate {
    title.text: `${TranslationManager.revision}` && qsTr("Modal Dialog Stack Test")

    // Profile Dialog
    Component {
        id: profileDialog

        ColumnLayout {
            id: root
            width: 450
            height: 400
            spacing: Theme.spacing.s4

            signal closed()

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Theme.colors.surface
                radius: Theme.radius.lg
                border.color: Theme.colors.border
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Theme.spacing.s6
                    spacing: Theme.spacing.s4

                    Text {
                        text: "Edit Profile"
                        font.pixelSize: 24
                        font.bold: true
                        color: Theme.colors.text
                    }

                    UI.Input {
                        Layout.fillWidth: true
                        labelText: "Name"
                        text: "John Doe"
                    }

                    UI.Input {
                        Layout.fillWidth: true
                        labelText: "Email"
                        text: "john.doe@example.com"
                    }

                    UI.Button {
                        Layout.fillWidth: true
                        text: "Change Password"
                        variant: UI.ButtonStyles.Secondary
                        onClicked: dialogStack.push(passwordDialog)
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacing.s3

                        UI.Button {
                            Layout.fillWidth: true
                            text: "Save"
                            variant: UI.ButtonStyles.Primary
                            onClicked: closed()
                        }

                        UI.Button {
                            Layout.fillWidth: true
                            text: "Cancel"
                            variant: UI.ButtonStyles.Ghost
                            onClicked: closed()
                        }
                    }
                }
            }
        }
    }

    // Password Dialog
    Component {
        id: passwordDialog

        ColumnLayout {
            id: root
            width: 400
            height: 300
            spacing: Theme.spacing.s4

            signal closed()

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Qt.lighter(Theme.colors.surface, 1.8)
                radius: Theme.radius.lg
                border.color: Theme.colors.border
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Theme.spacing.s6
                    spacing: Theme.spacing.s4

                    Text {
                        text: "Change Password"
                        font.pixelSize: 22
                        font.bold: true
                        color: Theme.colors.text
                    }

                    UI.Input {
                        Layout.fillWidth: true
                        labelText: "New Password"
                        textField.echoMode: TextInput.Password
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacing.s3

                        UI.Button {
                            Layout.fillWidth: true
                            text: "Update"
                            variant: UI.ButtonStyles.Primary
                            onClicked: closed()
                        }

                        UI.Button {
                            Layout.fillWidth: true
                            text: "Cancel"
                            variant: UI.ButtonStyles.Ghost
                            onClicked: closed()
                        }
                    }
                }
            }
        }
    }


    ScrollView {
        id: sv
        anchors.fill: parent

        Frame {
            padding: Theme.spacing.s4
            width: sv.availableWidth

            ColumnLayout {
                anchors.fill: parent
                spacing: Theme.spacing.s6

                Text {
                    text: "Modal Dialog Stack Test"
                    font.pixelSize: 24
                    font.bold: true
                    color: Theme.colors.text
                }

                UI.HorizontalDivider {}

                // User Card
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 300
                    color: Theme.colors.primary700
                    radius: Theme.radius.md
                    border.color: Theme.colors.border
                    border.width: 1

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: Theme.spacing.s3

                        UI.Avatar {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth: 80
                            Layout.preferredHeight: 80
                            source: "qrc:/App/assets/images/avatar.png"
                            radius: Theme.radius.circle(80, 80)
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "John Doe"
                            font.pixelSize: 20
                            font.bold: true
                            color: Theme.colors.text
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "john.doe@example.com"
                            color: Theme.colors.textMuted
                        }
                    }
                }

                UI.Button {
                    Layout.fillWidth: true
                    text: "Edit Profile Settings"
                    variant: UI.ButtonStyles.Primary
                    size: "lg"
                    onClicked: modal.push(profileDialog)
                }

                Text {
                    text: "Active Dialogs: " + modal.count
                    font.pixelSize: 16
                    color: Theme.colors.textMuted
                }

                UI.HorizontalDivider {}

                Text {
                    Layout.fillWidth: true
                    text: "Click 'Edit Profile Settings' to open the main dialog.\nInside, click 'Change Password' to stack another dialog on top!"
                    wrapMode: Text.WordWrap
                    color: Theme.colors.text
                }
            }
        }
    }

    // The Modal Dialog Stack
    UI.Modal {
        id: modal

        onDialogOpened: (dialog) => {
            console.log("Dialog opened:", dialog.id)
        }

        onDialogClosed: (dialog) => {
            console.log("Dialog closed:", dialog.id)
        }
    }
}
