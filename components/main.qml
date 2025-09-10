import QtQuick 6.8
import QtQuick.Controls.Fusion 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import QtQuick.Window 6.8

import raise.map.layers 1.0
import raise.singleton.panelmanager 1.0
import raise.singleton.trackmanager 1.0
import raise.singleton.language 1.0

Window {
    id: mainWindow
    visible: true
    width: 1600
    height: 800
    title: mainWindow.titleText

    // Automatic retranslation properties
    property string titleText: qsTr("MapLayers")

    // Auto-retranslate when language changes
    function retranslateUi() {
        titleText = qsTr("MapLayers")
    }

    // Automatic retranslation on language change
    Connections {
        target: LanguageController
        function onLanguageChanged() {
            console.log("Language changed signal received - auto-retranslating")
            mainWindow.retranslateUi()
        }
        function onLanguageLoadFailed(language, reason) {
            console.error("Language load failed:", language, "-", reason)
        }
    }

    WMSMapLayer {
        id: wmsmaplayer
    }

    // uiOverlay per pannelli ed altro
    Item {
        id: uiOverlay
        anchors.fill: parent
        z: 1000
    }

    Component.onCompleted: {
        PanelManager.uiOverlay = uiOverlay
    }

    Connections {
        target: PanelManager

        function onCenterViewRequested(coordinate) {
            wmsmaplayer.map.center = coordinate
        }
    }

    Connections {
        target: TrackManager

        function onDeactivated() {
            PanelManager.closeCurrent();
        }
    }
}
