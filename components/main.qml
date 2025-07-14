import QtQuick 6.8
import QtQuick.Controls.Fusion 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import QtQuick.Window 6.8

import raise.map.layers 1.0
import raise.singleton.panelmanager 1.0
import raise.singleton.trackmanager 1.0

Window {
    id: mainWindow
    visible: true
    width: 1600
    height: 800
    title: "MapLayers"

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
