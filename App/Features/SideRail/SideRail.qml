import QtQuick 6.8
import QtQuick.Layouts 6.8

import App.Components 1.0 as UI
import App.Themes 1.0

UI.GlobalBackgroundConsumer {
    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.spacing.s2
        z: Theme.elevation.panel

        UI.VerticalPadding { }

        Image {
            source: "qrc:/App/assets/images/logo.png"
            Layout.preferredWidth: Theme.icons.sizeLogo
            Layout.preferredHeight: Theme.icons.sizeLogo
            Layout.alignment: Qt.AlignCenter
        }

        Text {
            text: "OK"
        }

        UI.VerticalSpacer { }

        UI.VerticalPadding { }
    }
}
