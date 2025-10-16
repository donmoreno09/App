import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Features.TitleBar 1.0
import App.Features.SidePanel 1.0
import App.Features.Language 1.0
import App.Features.Mission 1.0
import App.Features.TrackPanel 1.0
import App.Features.TruckArrivals 1.0
import App.Features.TrailerPredictions 1.0
import App.Features.ViGateServices 1.0
import App.Components 1.0 as UI

UI.GlobalBackgroundConsumer {
    id: sidePanel

    StackView {
        id: stackView
        anchors.fill: parent

        Component.onCompleted: {
            PanelRouter.stackView = stackView
        }
    }

    Component.onCompleted: {
        SidePanelController.attach(sidePanel)
    }

    Connections {
        target: LanguageController
        function onLanguageChanged() {
            if (stackView.currentItem && PanelRouter.currentPath) {
                // Temporarily disable transitions
                var oldTransition = stackView.replaceEnter
                var oldExitTransition = stackView.replaceExit
                stackView.replaceEnter = null
                stackView.replaceExit = null

                PanelRouter.replaceCurrent(PanelRouter.currentPath)

                // Restore transitions
                stackView.replaceEnter = oldTransition
                stackView.replaceExit = oldExitTransition
            }
        }
    }
}
