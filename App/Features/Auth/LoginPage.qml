import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App 1.0
import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.TitleBar 1.0

Rectangle {
    id: root
    color: Theme.colors.background

    readonly property bool isBusy: AuthService.state === AuthStateEnum.LoggingIn
                                   || AuthService.state === AuthStateEnum.AutoLoggingIn
    readonly property bool hasError: AuthService.state === AuthStateEnum.Error

    WindowControlsBar {
        anchors.top:   parent.top
        anchors.left:  parent.left
        anchors.right: parent.right
    }

    Rectangle {
        id: card
        anchors.centerIn: parent
        width:        Theme.layout.loginCardWidth
        height:       cardContent.implicitHeight + Theme.spacing.s8 * 2
        radius:       Theme.radius.lg
        color:        Theme.colors.whiteA5
        border.color: Theme.colors.whiteA10
        border.width: Theme.borders.b1

        ColumnLayout {
            id: cardContent
            anchors {
                top:         parent.top
                left:        parent.left
                right:       parent.right
                topMargin:   Theme.spacing.s8
                leftMargin:  Theme.spacing.s6
                rightMargin: Theme.spacing.s6
            }
            spacing: Theme.spacing.s4

            Text {
                Layout.alignment: Qt.AlignHCenter
                text:               "FINCANTIERI"
                color:              Theme.colors.text
                font.family:        Theme.typography.familySans
                font.pointSize:     Theme.typography.fontSize200
                font.weight:        Theme.typography.weightBold
                font.letterSpacing: Theme.typography.letterSpacingLoose
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text:           qsTr("Log in Fincantieri Digital Ecosystem")
                color:          Theme.colors.textMuted
                font.family:    Theme.typography.familySans
                font.pointSize: Theme.typography.bodySans25Size
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                visible:        AuthService.state === AuthStateEnum.AutoLoggingIn
                text:           qsTr("Restoring session...")
                color:          Theme.colors.textMuted
                font.family:    Theme.typography.familySans
                font.pointSize: Theme.typography.bodySans25Size
            }

            ColumnLayout {
                Layout.fillWidth: true
                visible: AuthService.state !== AuthStateEnum.AutoLoggingIn
                spacing: Theme.spacing.s4

                UI.Input {
                    id: authIdInput
                    Layout.fillWidth: true
                    labelText: qsTr("Authentication ID")
                    enabled:   !root.isBusy
                    variant:   root.hasError ? UI.InputStyles.Error : UI.InputStyles.Default
                    textField.Keys.onReturnPressed: if (loginBtn.canLogin) loginBtn.doLogin()
                }

                UI.Input {
                    id: passwordInput
                    Layout.fillWidth: true
                    labelText: qsTr("Password")
                    echoMode:  TextInput.Password
                    enabled:   !root.isBusy
                    variant:   root.hasError ? UI.InputStyles.Error : UI.InputStyles.Default
                    textField.Keys.onReturnPressed: if (loginBtn.canLogin) loginBtn.doLogin()
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacing.s2

                    UI.Checkbox {
                        id:      rememberMeCheck
                        text:    qsTr("Remember me")
                        enabled: !root.isBusy
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text:           qsTr("Forgot password?")
                        color:          Theme.colors.textMuted
                        font.family:    Theme.typography.familySans
                        font.pointSize: Theme.typography.bodySans15Size
                        font.underline: true
                        HoverHandler { cursorShape: Qt.PointingHandCursor }
                        TapHandler   { onTapped: console.log("[Login] Forgot password") }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    visible:             root.hasError && AuthService.errorMessage !== ""
                    text:                AuthService.errorMessage
                    color:               Theme.colors.error
                    wrapMode:            Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    font.family:         Theme.typography.familySans
                    font.pointSize:      Theme.typography.bodySans25Size
                }

                UI.Button {
                    id: loginBtn
                    Layout.fillWidth: true

                    readonly property bool canLogin: !root.isBusy
                                                     && authIdInput.text.length > 0
                                                     && passwordInput.text.length > 0

                    function doLogin() {
                        AuthService.login(authIdInput.text, passwordInput.text, rememberMeCheck.checked)
                    }

                    variant: UI.ButtonStyles.Primary
                    enabled: canLogin
                    text:    AuthService.state === AuthStateEnum.LoggingIn
                             ? qsTr("Logging in...") : qsTr("Login")

                    onClicked: doLogin()
                }
            }
        }
    }

    Connections {
        target: AuthService
        function onLoginSucceeded() {
            authIdInput.text   = ""
            passwordInput.text = ""
        }
    }
}
