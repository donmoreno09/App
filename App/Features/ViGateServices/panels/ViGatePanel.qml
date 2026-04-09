import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Features.Panels 1.0
import App.Features.ViGateServices 1.0
import App.Features.Language 1.0
import App.Components 1.0 as UI

PanelTemplate {
    title.text: `${TranslationManager.revision}` && qsTr("Gate Transits")
    clip: true

    property var ctrl: ViGateController

    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth

        Pane {
            anchors.fill: parent
            padding: Theme.spacing.s8
            background: Rectangle { color: Theme.colors.transparent }

            ViGateContent {
                id: contentComponent
                width: parent.width
                controller: ctrl
            }
        }
    }

    footer: ColumnLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: Theme.spacing.s0

        UI.HorizontalDivider { color: Theme.colors.whiteA10 }

        Pane {
            Layout.fillWidth: true
            padding: Theme.spacing.s8
            background: Rectangle { color: Theme.colors.transparent }

            RowLayout {
                anchors.fill: parent
                spacing: Theme.spacing.s4

                UI.HorizontalSpacer { Layout.preferredWidth: 1 }

                UI.Button {
                    Layout.preferredWidth: 1
                    Layout.fillWidth: true
                    text: qsTr("Fetch Arrivals")
                    enabled: !ctrl.isLoading && contentComponent.canFetch
                    onClicked: {
                        Qt.inputMethod.commit()

                        ctrl.fetchGateData(
                            contentComponent.selectedGateId,
                            contentComponent.startDT,
                            contentComponent.endDT,
                            contentComponent.vehiclesChecked,
                            contentComponent.pedestriansChecked,
                            5
                        )
                    }
                }
            }
        }
    }
}
