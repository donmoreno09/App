import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.SidePanel 1.0
import App.Features.Language 1.0
import App.Features.WebComponent 1.0

PanelTemplate {
    id: root

    title.text: (TranslationManager.revision, qsTr("Web Component"))

    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth
        clip: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.spacing.s6
            spacing: Theme.spacing.s6

            // Header
            Text {
                text: (TranslationManager.revision, qsTr("Ship Stowage"))
                color: Theme.colors.text
                font.family: Theme.typography.familySans
                font.pixelSize: Theme.typography.fontSize300
                font.weight: Theme.typography.weightMedium
                Layout.alignment: Qt.AlignHCenter
            }

            // Description
            Text {
                text: (TranslationManager.revision, qsTr("View and manage ship stowage information in an embedded web interface."))
                color: Theme.colors.textMuted
                font.family: Theme.typography.familySans
                font.pixelSize: Theme.typography.fontSize150
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
            }

            UI.VerticalSpacer { }

            // Launch button
            UI.Button {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 280
                Layout.preferredHeight: Theme.spacing.s10
                variant: UI.ButtonStyles.Primary
                text: (TranslationManager.revision, qsTr("Open Stowage - FourClicks"))

                icon.source: "qrc:/App/assets/icons/world.svg"
                icon.width: Theme.icons.sizeMd
                icon.height: Theme.icons.sizeMd

                onClicked: {
                    const component = Qt.createComponent("qrc:/App/Features/WebComponent/components/DraggableWebContainer.qml")

                    if (component.status === Component.Error) {
                        console.error("Error loading component:", component.errorString())
                        return
                    }

                    const appWindow = root.Window.window
                    const webContainer = component.createObject(appWindow.contentItem, {
                        x: (appWindow.width - 800) / 2,
                        y: (appWindow.height - 600) / 2,
                        width: 800,
                        height: 600,
                        webViewUrl: "https://mbpv.fourclicks.it/#/ships/101?token=eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJkMGM4ZDI5Yi1lM2EyLTRhNzgtODQ1ZS02MDAwYWNhYTlmZWQifQ.eyJpYXQiOjE3NDkyMTQ5NTEsImp0aSI6IjQyNTk2YWY2LTM3OWYtNDMxYi05ZDBmLTk1MjhiMGMyNWI0YiIsImlzcyI6Imh0dHBzOi8vYWRtaW4uZm91cmNsaWNrcy5pdC9hdXRoL3JlYWxtcy9tYnB2IiwiYXVkIjoiaHR0cHM6Ly9hZG1pbi5mb3VyY2xpY2tzLml0L2F1dGgvcmVhbG1zL21icHYiLCJzdWIiOiJmYzAwZTUwZi1jYzZkLTQxNzEtODJjMy01MmE2OTQ5NTQ1YzgiLCJ0eXAiOiJPZmZsaW5lIiwiYXpwIjoibWJwdi1mcm9udGVuZCIsInNlc3Npb25fc3RhdGUiOiIwOGI3MThiOS1lOTdiLTRiNDktODk2OS0wNTdkMWQ5Mjg0NTIiLCJzY29wZSI6InByb2ZpbGUgb2ZmbGluZV9hY2Nlc3MgZW1haWwiLCJzaWQiOiIwOGI3MThiOS1lOTdiLTRiNDktODk2OS0wNTdkMWQ5Mjg0NTIifQ.OX81tY7LNifwUsX0muq1tcPGXPq-BnilG3KHp19IsVE"
                    })

                    if (!webContainer) {
                        console.error("Failed to create web container")
                        return
                    }

                    webContainer.closeRequested.connect(function() {
                        webContainer.destroy()
                    })
                }
            }

            UI.VerticalSpacer { }

            // Info section
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: infoLayout.implicitHeight + Theme.spacing.s6
                color: Theme.colors.glass
                border.color: Theme.colors.glassBorder
                border.width: Theme.borders.b1
                radius: Theme.radius.sm

                ColumnLayout {
                    id: infoLayout
                    anchors.fill: parent
                    anchors.margins: Theme.spacing.s4
                    spacing: Theme.spacing.s2

                    Text {
                        text: (TranslationManager.revision, qsTr("Features"))
                        color: Theme.colors.text
                        font.family: Theme.typography.familySans
                        font.pixelSize: Theme.typography.fontSize150
                        font.weight: Theme.typography.weightSemibold
                    }

                    Repeater {
                        model: [
                            (TranslationManager.revision, qsTr("• Draggable window")),
                            (TranslationManager.revision, qsTr("• Resizable viewport")),
                            (TranslationManager.revision, qsTr("• Full web functionality")),
                            (TranslationManager.revision, qsTr("• JavaScript enabled"))
                        ]

                        Text {
                            text: modelData
                            color: Theme.colors.textMuted
                            font.family: Theme.typography.familySans
                            font.pixelSize: Theme.typography.fontSize150
                            Layout.fillWidth: true
                        }
                    }
                }
            }

            UI.VerticalSpacer { }
        }
    }
}
