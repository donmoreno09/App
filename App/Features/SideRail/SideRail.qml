import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Components 1.0 as UI
import App.Themes 1.0

UI.GlobalBackgroundConsumer {
    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.spacing.s0
        z: Theme.elevation.panel

        UI.VerticalPadding { }

        Image {
            source: "qrc:/App/assets/images/logo.png"
            Layout.preferredWidth: Theme.icons.sizeLogo
            Layout.preferredHeight: Theme.icons.sizeLogo
            Layout.alignment: Qt.AlignCenter
        }

        UI.VerticalPadding { }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.s0

            SideRailItem {
                source: "qrc:/App/assets/icons/clipboard.svg"
                label: "Mission"
            }

            SideRailItem {
                source: "qrc:/App/assets/icons/submarine.svg"
                label: "Pod"
            }
        }

        UI.VerticalSpacer { }

        UI.VerticalPadding { }
    }
}
