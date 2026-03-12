import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.Panels 1.0
import App.Features.Language 1.0

PanelTemplate {
    title.text: `${TranslationManager.revision}` && qsTr("Cluster Test")

    ScrollView {
        id: sv
        anchors.fill: parent

        Frame {
            padding: Theme.spacing.s4
            width: sv.availableWidth

            RowLayout {
                id: stateRow
                anchors.centerIn: parent
                spacing: Theme.spacing.s12

                // Default
                ColumnLayout {
                    spacing: Theme.spacing.s3
                    Layout.alignment: Qt.AlignHCenter

                    UI.Cluster {
                        Layout.alignment: Qt.AlignHCenter
                        clusterNumber: 2
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text:           "Default"
                        color:          Theme.colors.textMuted
                        font.pixelSize: Theme.typography.fontSize125
                    }
                }

                // Hover
                ColumnLayout {
                    spacing: Theme.spacing.s3
                    Layout.alignment: Qt.AlignHCenter

                    UI.Cluster {
                        Layout.alignment: Qt.AlignHCenter
                        clusterNumber: 2
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text:           "Hover"
                        color:          Theme.colors.textMuted
                        font.pixelSize: Theme.typography.fontSize125
                    }
                }

                // Selected
                ColumnLayout {
                    spacing: Theme.spacing.s3
                    Layout.alignment: Qt.AlignHCenter

                    UI.Cluster {
                        Layout.alignment: Qt.AlignHCenter
                        clusterNumber: 2
                        selected: true
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text:           "Selected"
                        color:          Theme.colors.textMuted
                        font.pixelSize: Theme.typography.fontSize125
                    }
                }

                // Disabled
                ColumnLayout {
                    spacing: Theme.spacing.s3
                    Layout.alignment: Qt.AlignHCenter

                    UI.Cluster {
                        Layout.alignment: Qt.AlignHCenter
                        clusterNumber: 2
                        enabled: false
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text:           "Disabled"
                        color:          Theme.colors.textMuted
                        font.pixelSize: Theme.typography.fontSize125
                    }
                }
            }
        }
    }
}
