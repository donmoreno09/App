import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App 1.0
import App.Themes 1.0
import App.Components 1.0 as UI

Rectangle {
    id: root
    color: Theme.colors.background

    readonly property bool isBusy: AuthService.state === AuthStateEnum.LoggingIn
                                   || AuthService.state === AuthStateEnum.AutoLoggingIn
    readonly property bool hasError: AuthService.state === AuthStateEnum.Error

    ColumnLayout {
        anchors.centerIn: parent
        width: 400
        spacing: Theme.spacing.s5

        // Logo
        Image {
            source: "qrc:/App/assets/logo-app.ico"
            Layout.preferredWidth: 64
            Layout.preferredHeight: 64
            Layout.alignment: Qt.AlignHCenter
            fillMode: Image.PreserveAspectFit
        }

        // Title
        Text {
            text: "IRIDESS"
            color: Theme.colors.text
            font {
                family: Theme.typography.familySans
                pointSize: 24
                weight: Font.Bold
            }
            Layout.alignment: Qt.AlignHCenter
        }

        // Subtitle
        Text {
            text: qsTr("Maritime Monitoring System")
            color: Theme.colors.textMuted
            font {
                family: Theme.typography.familySans
                pointSize: Theme.typography.bodySans25Size
            }
            Layout.alignment: Qt.AlignHCenter
        }

        // Spacer
        Item { Layout.preferredHeight: Theme.spacing.s3 }

        // Auto-login message
        Text {
            text: qsTr("Restoring session...")
            color: Theme.colors.textMuted
            font {
                family: Theme.typography.familySans
                pointSize: Theme.typography.bodySans25Size
            }
            visible: AuthService.state === AuthStateEnum.AutoLoggingIn
            Layout.alignment: Qt.AlignHCenter
        }

        // Username
        UI.Input {
            id: usernameInput
            labelText: qsTr("Username")
            placeholderText: qsTr("Enter username")
            Layout.fillWidth: true
            enabled: !root.isBusy
            visible: AuthService.state !== AuthStateEnum.AutoLoggingIn
            variant: root.hasError ? InputStyles.Error : InputStyles.Default
        }

        // Password
        UI.Input {
            id: passwordInput
            labelText: qsTr("Password")
            placeholderText: qsTr("Enter password")
            echoMode: TextInput.Password
            Layout.fillWidth: true
            enabled: !root.isBusy
            visible: AuthService.state !== AuthStateEnum.AutoLoggingIn
            variant: root.hasError ? InputStyles.Error : InputStyles.Default

            textField.Keys.onReturnPressed: {
                if (loginButton.enabled) loginButton.clicked()
            }
        }

        // Error message
        Text {
            text: AuthService.errorMessage
            color: Theme.colors.error
            font {
                family: Theme.typography.familySans
                pointSize: Theme.typography.bodySans25Size
            }
            visible: root.hasError && AuthService.errorMessage !== ""
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }

        // Login button
        UI.Button {
            id: loginButton
            text: AuthService.state === AuthStateEnum.LoggingIn
                  ? qsTr("Logging in...") : qsTr("Login")
            Layout.fillWidth: true
            visible: AuthService.state !== AuthStateEnum.AutoLoggingIn
            enabled: !root.isBusy
                     && usernameInput.text.length > 0
                     && passwordInput.text.length > 0
            onClicked: AuthService.login(usernameInput.text, passwordInput.text)
        }
    }

    // Clear fields on successful login
    Connections {
        target: AuthService
        function onLoginSucceeded() {
            usernameInput.text = ""
            passwordInput.text = ""
        }
    }
}
