import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.Language 1.0

UI.GlobalBackgroundConsumer {
    id: root

    StackView {
        id: stackView
        anchors.fill: parent

        Component.onCompleted: {
            ContextPanelController.router.stackView = stackView
        }
    }

    Connections {
        target: LanguageController
        function onLanguageChanged() {
            if (stackView.currentItem && ContextPanelController.router.currentPath) {
                // Temporarily disable transitions
                var oldTransition = stackView.replaceEnter
                var oldExitTransition = stackView.replaceExit
                stackView.replaceEnter = null
                stackView.replaceExit = null

                ContextPanelController.router.replaceCurrent(ContextPanelController.router.currentPath)

                // Restore transitions
                stackView.replaceEnter = oldTransition
                stackView.replaceExit = oldExitTransition
            }
        }
    }
}
