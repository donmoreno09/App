import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8
import raise.map.layers 1.0
import raise.singleton.layermanager 1.0
import raise.singleton.trackmanager 1.0
import raise.singleton.mqtt 1.0

MapItemGroup {
    id: trackMapLayerComponent

    property real zoomLevel: 0
    property alias isVisible: trackMapLayerBusinessLogic.isVisible
    property alias isEnabled: trackMapLayerBusinessLogic.isEnabled

    property string layerName: "TrackMapLayer"

    visible: isVisible

    Component {
        id: trackDelegate

        MapQuickItem {
            id: item
            coordinate: QtPositioning.coordinate(modelData.pos[0], modelData.pos[1])
            anchorPoint.x: 40
            anchorPoint.y: 40

            sourceItem: Rectangle {
                width: 40
                height: 40
                radius: 2
                color: "blue"
                border.color: "white"
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: modelData.name
                    font.pixelSize: 12
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.Wrap
                }
            }

            Component.onCompleted: {
                mapView.addMapItem(item)
            }

            Component.onDestruction: {
                mapView.removeMapItem(item)
            }
        }
    }

    Repeater {
        id: repeaterTracks
        model: trackMapLayerBusinessLogic.tracks
        delegate: trackDelegate
    }

    Component.onCompleted: {
        console.log("[TrackMapLayerComponent:Component.onCompleted] layer : " + trackMapLayerComponent.layerName + " notify layer ready...")
        LayerManager.registerLayer(trackMapLayerBusinessLogic)
        TrackManager.registerLayer("ais", trackMapLayerBusinessLogic)
        MqttClientService.registerLayer("TrackLayer1", trackMapLayerBusinessLogic);
        trackMapLayerBusinessLogic.initialize()
    }

    TrackMapLayer {
        id: trackMapLayerBusinessLogic
        layerName: trackMapLayerComponent.layerName
        zoomLevel: trackMapLayerComponent.zoomLevel
    }

    Connections {
        target: trackMapLayerBusinessLogic

        function onLayerReady() {
            LayerManager.notifyLayerReady(trackMapLayerBusinessLogic)
        }

        function onActivated() {
            console.log("AIS ACTIVATED!")
            trackMapLayerComponent.visible = true
        }

        function onDeactivated() {
            console.log("AIS DEACTIVATED!")
            trackMapLayerComponent.visible = false
        }
    }
}
