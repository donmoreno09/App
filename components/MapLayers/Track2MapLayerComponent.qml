import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8
import raise.map.layers 1.0
import raise.singleton.layermanager 1.0

MapItemGroup {
    id: trackMapLayerComponent

    property real zoomLevel: 0
    property alias isVisible: trackMapLayerBusinessLogic.isVisible
    property alias isEnabled: trackMapLayerBusinessLogic.isEnabled

    property string layerName: "TrackMap2Layer"

    visible: isVisible

    property var hardcodedTracks: [
        { id: "TIR-01", latitude: 44.1047, longitude: 9.8250, label: "Belva10", color: "pink" },
        { id: "TIR-02", latitude: 44.1020, longitude: 9.8215, label: "Drago", color: "pink" },
        { id: "TIR-03", latitude: 44.0960, longitude: 9.8300, label: "Goliat", color: "pink" },
        { id: "TIR-04", latitude: 44.1055, longitude: 9.8240, label: "Titan", color: "pink" },
        { id: "TIR-05", latitude: 44.1030, longitude: 9.8275, label: "Mammut", color: "pink" },
        { id: "TIR-06", latitude: 44.1015, longitude: 9.8290, label: "Centauro", color: "pink" },
        { id: "TIR-07", latitude: 44.0980, longitude: 9.8310, label: "Cyclope", color: "pink" },
        { id: "TIR-08", latitude: 44.1000, longitude: 9.8230, label: "Ercole", color: "pink" }
    ]


    Component {
        id: trackDelegate

        MapQuickItem {
            coordinate: QtPositioning.coordinate(modelData.latitude, modelData.longitude)
            anchorPoint.x: 40
            anchorPoint.y: 40

            sourceItem: Rectangle {
                width: 40
                height: 40
                radius: 2
                color: modelData.color
                border.color: "white"
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: modelData.label
                    font.pixelSize: 12
                    color: "black"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.Wrap
                }
            }
        }
    }

    Repeater {
        model: hardcodedTracks
        delegate: trackDelegate
    }

    Component.onCompleted: {
        console.log("[TrackMapLayerComponent:Component.onCompleted] layer : " + trackMapLayerComponent.layerName + " notify layer ready...")

        trackMapLayerBusinessLogic.tracks = hardcodedTracks
        LayerManager.registerLayer(trackMapLayerBusinessLogic)
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
    }
}
