import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import QtQuick.Shapes 6.8

import App 1.0
import App.Auth 1.0
import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.TitleBar 1.0

Item {
    id: root

    readonly property bool isBusy:   AuthManager.state === AuthStateEnum.LoggingIn || AuthManager.state === AuthStateEnum.AutoLoggingIn
    readonly property bool hasError: AuthManager.state === AuthStateEnum.Error
    readonly property bool canLogin: !isBusy && authIdInput.text !== "" && passwordInput.text !== ""

    UI.GlobalBackground {
        anchors.fill: parent
        visible: true
    }

    WindowControlsBar {
        anchors.top:   parent.top
        anchors.left:  parent.left
        anchors.right: parent.right
    }

    TapHandler    { acceptedButtons: Qt.AllButtons }
    HoverHandler  { }

    Item {
        id: card
        anchors.centerIn: parent
        width:  Theme.layout.loginCardWidth
        height: cardContent.implicitHeight + Theme.spacing.s8 * 2

        readonly property real chamferSize: 24
        readonly property real borderWidth: Theme.borders.b1

        Shape {
            anchors.fill: parent

            ShapePath {
                fillColor:   Theme.colors.loginCard
                strokeColor: Theme.colors.whiteA10
                strokeWidth: card.borderWidth
                startX: 0; startY: 0

                PathLine { x: card.width - card.chamferSize; y: 0 }
                PathLine { x: card.width;                    y: card.chamferSize }
                PathLine { x: card.width;                    y: card.height }
                PathLine { x: 0;                             y: card.height }
                PathLine { x: 0;                             y: 0 }
            }
        }

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

            Image {
                Layout.alignment:      Qt.AlignHCenter
                Layout.preferredHeight: Theme.icons.sizeXs
                source:               "qrc:/App/assets/icons/fincantieri.svg"
                fillMode:             Image.PreserveAspectFit
                sourceSize.height:    Theme.icons.sizeLogo
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
                visible:        AuthManager.state === AuthStateEnum.AutoLoggingIn
                text:           qsTr("Restoring session...")
                color:          Theme.colors.textMuted
                font.family:    Theme.typography.familySans
                font.pointSize: Theme.typography.bodySans25Size
            }

            ColumnLayout {
                Layout.fillWidth: true
                visible: AuthManager.state !== AuthStateEnum.AutoLoggingIn
                spacing: Theme.spacing.s4

                UI.AlertBanner {
                    Layout.fillWidth: true
                    visible: root.hasError
                    variant: UI.AlertBannerStyles.Error
                    title:   qsTr("The credentials you entered are invalid.")
                    message: qsTr("Please enter valid credentials and try again.")
                }

                UI.Input {
                    id: authIdInput
                    Layout.fillWidth: true
                    labelText: qsTr("Authentication ID")
                    enabled:   !root.isBusy
                    variant:   root.hasError ? UI.InputStyles.Error : UI.InputStyles.Default
                    textField.Keys.onReturnPressed: if (root.canLogin) root.doLogin()
                }

                UI.Input {
                    id: passwordInput
                    Layout.fillWidth: true
                    labelText: qsTr("Password")
                    echoMode:  TextInput.Password
                    enabled:   !root.isBusy
                    variant:   root.hasError ? UI.InputStyles.Error : UI.InputStyles.Default
                    textField.Keys.onReturnPressed: if (root.canLogin) AuthManager.login(authIdInput.text, passwordInput.text, rememberMeCheck.checked)
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

                UI.Button {
                    Layout.fillWidth: true
                    enabled:  root.canLogin
                    variant:  UI.ButtonStyles.PrimaryDarkMode
                    radius: Theme.radius.none
                    text:     AuthManager.state === AuthStateEnum.LoggingIn ? qsTr("Logging in...") : qsTr("Login")
                    onClicked: AuthManager.login(authIdInput.text, passwordInput.text, rememberMeCheck.checked)
                }
            }
        }
    }

    Connections {
        target: AuthManager
        function onLoginSucceeded() {
            authIdInput.text   = ""
            passwordInput.text = ""
        }
    }
}
