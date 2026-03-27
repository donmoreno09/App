import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import QtQuick.Shapes 6.8

import App 1.0
import App.Auth 1.0
import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.TitleBar 1.0

Rectangle {
    id: root
    color: Theme.colors.bg

    readonly property bool isBusy:   AuthManager.state === AuthStateEnum.LoggingIn || AuthManager.state === AuthStateEnum.AutoLoggingIn
    readonly property bool hasError: AuthManager.state === AuthStateEnum.Error
    readonly property bool canLogin: !isBusy && authIdInput.text !== "" && passwordInput.text !== ""

    property bool passwordVisible: false

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

        readonly property real chamferSize: Theme.spacing.s5
        readonly property real borderWidth: Theme.borders.b1

        Shape {
            anchors.fill: parent

            ShapePath {
                fillColor:   Theme.colors.whiteA10
                strokeColor: Theme.colors.whiteA10
                strokeWidth: card.borderWidth
                startX: 0; startY: 0

                PathLine { x: card.width - card.chamferSize; y: 0 }
                PathLine { x: card.width;                    y: card.chamferSize }
                PathLine { x: card.width;                    y: card.height }
                PathLine { x: 0;                             y: card.height }
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
                Layout.preferredHeight: Theme.icons.sizeSm
                source:               "qrc:/App/assets/icons/fincantieri.svg"
                fillMode:             Image.PreserveAspectFit
                sourceSize.height:    Theme.icons.sizeLogo
            }

            Image {
                Layout.alignment:      Qt.AlignHCenter
                Layout.preferredHeight: Theme.icons.loginDivider
                source:               "qrc:/App/assets/icons/login_divider.svg"
                fillMode:             Image.PreserveAspectFit
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text:           qsTr("Log in Fincantieri Digital Ecosystem")
                color:          Theme.colors.text
                font.family:    Theme.typography.familySans
                font.pointSize: Theme.typography.bodySans50Size
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
                    visible: AuthManager.sessionExpired
                    variant: UI.AlertBannerStyles.Error
                    title:   qsTr("Your session has ended.")
                    message: qsTr("To continue, please log in again.")
                }

                UI.AlertBanner {
                    Layout.fillWidth: true
                    visible: root.hasError
                    variant: UI.AlertBannerStyles.Error
                    title: qsTr("The credentials you entered are invalid. Please enter valid credentials and try again.")
                }

                UI.Input {
                    id: authIdInput
                    Layout.fillWidth: true
                    labelText: qsTr("E-mail")
                    enabled:   !root.isBusy
                    variant:   root.hasError ? UI.InputStyles.Error : UI.InputStyles.Default
                    textField.Keys.onReturnPressed: if (root.canLogin) AuthManager.login(authIdInput.text, passwordInput.text, rememberMeCheck.checked)
                }

                UI.Input {
                    id: passwordInput
                    Layout.fillWidth: true
                    labelText:         qsTr("Password")
                    echoMode:          passwordVisible ? TextInput.Normal : TextInput.Password
                    iconSource:              "qrc:/App/assets/icons/login-eye.svg"
                    iconButton.icon.color:   Qt.rgba(0, 0, 0, 0)
                    iconButton.icon.width:   16
                    iconButton.icon.height:  13
                    enabled:           !root.isBusy
                    variant:           root.hasError ? UI.InputStyles.Error : UI.InputStyles.Default
                    textField.Keys.onReturnPressed: if (root.canLogin) AuthManager.login(authIdInput.text, passwordInput.text, rememberMeCheck.checked)
                    onIconClicked: passwordVisible = !passwordVisible
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacing.s2

                    UI.Checkbox {
                        id:      rememberMeCheck
                        size:    "lg"
                        text:    qsTr("Remember me")
                        enabled: !root.isBusy
                    }

                    Item { Layout.fillWidth: true }

                    Item {
                        implicitWidth: forgotText.implicitWidth
                        implicitHeight: forgotText.implicitHeight + Theme.spacing.s1

                        HoverHandler { cursorShape: Qt.PointingHandCursor }
                        TapHandler { onTapped: console.log("[Login] Forgot password") }

                        Text {
                            id: forgotText
                            text: qsTr("Forgot password?")
                            color: Theme.colors.text
                            font.family: Theme.typography.familySans
                            font.pointSize: Theme.typography.bodySans50Size
                        }

                        Shape {
                            anchors.top: forgotText.bottom
                            anchors.topMargin: Theme.spacing.s0_5
                            width: forgotText.width
                            height: Theme.spacing.s0_5

                            ShapePath {
                                strokeWidth: Theme.borders.b1
                                strokeColor: Theme.colors.text
                                fillColor: "transparent"
                                strokeStyle: ShapePath.DashLine
                                dashPattern: [1, 2]

                                startX: 0
                                startY: 1
                                PathLine { x: forgotText.width; y: 1 }
                            }
                        }
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
