import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8
import raise.map.layers 1.0
import raise.singleton.layermanager 1.0
import raise.singleton.mqtt 1.0
import "../ui/tracks"

MapItemGroup {
    id: trackMapLayerComponent

    property real zoomLevel: 0
    property alias isVisible: trackMapLayerBusinessLogic.isVisible
    property alias isEnabled: trackMapLayerBusinessLogic.isEnabled

    property string layerName: "TrackMapLayer"

    visible: isVisible

    // ✅ Loader per il pannello del track
    Loader {
        id: panelLoader
        active: false
        asynchronous: true
        visible: false
        source: "../ui/legacy/panels/track/BaseTrackPanel.qml"

        // proprietà temporanee per passaggio dati
        property var trackData
        property var marker

        onLoaded: {
            if (panelLoader.item) {
                console.log("[TrackPanel] pannello caricato, inizializzo...")

                panelLoader.item.marker = panelLoader.marker
                panelLoader.item.trackData = panelLoader.trackData
                panelLoader.item.trackUid = panelLoader.trackData.iridess_uid || "unknown"
                panelLoader.item.trackChannel = "smartport"

                panelLoader.item.open(panelLoader.marker, panelLoader.item)
            } else {
                console.warn("[TrackPanel] panelLoader.item è null dopo onLoaded")
            }
        }

        onStatusChanged: {
            if (status === Loader.Error) {
                console.error("[TrackPanel] Errore nel caricamento del pannello:"
                              + " status=" + panelLoader.status
                              + " msg="    + panelLoader.errorString);   // ← senza ()
            }
        }
    }

    // ✅ Funzione pubblica per apertura pannello
    function showTrackPanel(trackData, marker) {
        console.log("[TrackPanel] showTrackPanel invoked")

        // resetta se già attivo
        panelLoader.active = false

        // setta i dati
        panelLoader.trackData = trackData
        panelLoader.marker = marker

        // avvia il loader
        panelLoader.active = true
    }

    // ✅ Delegate per ogni traccia (Marker)
    Component {
        id: trackDelegate

        Track {
            id: marker
            onRequestPanel: function(trackData, markerItem) {
                console.log("[TrackPanel] show track panel")
                trackMapLayerComponent.showTrackPanel(trackData, markerItem)
            }
        }
    }

    // ✅ Repeater delle tracce
    Repeater {
        id: repeaterTracks
        model: trackMapLayerBusinessLogic.tracks
        delegate: trackDelegate
    }

    // ✅ Registrazione layer su completamento
    Component.onCompleted: {
        console.log("[TrackMapLayerComponent:Component.onCompleted] layer : " + trackMapLayerComponent.layerName + " notify layer ready...")
        LayerManager.registerLayer(trackMapLayerBusinessLogic)
        MqttClientService.registerLayer("TrackLayer1", trackMapLayerBusinessLogic);
        trackMapLayerBusinessLogic.initialize()
    }

    // ✅ Backend C++ per la logica delle tracce
    TrackMapLayer {
        id: trackMapLayerBusinessLogic
        layerName: trackMapLayerComponent.layerName
        zoomLevel: trackMapLayerComponent.zoomLevel
    }

    // ✅ Notifica layer ready via Connections
    Connections {
        target: trackMapLayerBusinessLogic
        function onLayerReady() {
            LayerManager.notifyLayerReady(trackMapLayerBusinessLogic)
        }
    }
}
