import QtQuick 6.8
import QtQuick.Controls 6.8
import QtLocation 6.8
import QtPositioning 6.8
import raise.singleton.layermanager 1.0
import raise.singleton.interactionmanager 1.0
import raise.singleton.controllers 1.0
import raise.singleton.language 1.0

import "MapLayers"
import "ui"
import "SidePannel"
import "ui/top-toolbar"
import "ui/legacy/radial-menu"
import "handlers"
import "ui/tracks"

Item {
    id: root
    anchors.fill: parent
    z: 999
    property var mapLayers: []
    property int layerReadyCount: 0
    property int expectedLayers: 4
    property bool globalVisibility: true
    property var selectionPoints: []
    property int currentMode: InteractionModeManager.currentMode

    // Automatic retranslation properties
    property string createShapeText: qsTr("Create new shape")

    // Auto-retranslate when language changes
    function retranslateUi() {
        createShapeText = qsTr("Create new shape")
    }

    // expose these "global" components for now
    property alias topToolbar: topToolbar
    property alias insertPopupPoi: insertPoiPopup
    property alias staticPoiLayerInstance: staticPoiLayerComponentIstance
    property alias annotationLayerInstance: annotationLayerComponentIstance
    property alias map: mapView

    Plugin {
        id: mapPlugin
        name: "osm"
        PluginParameter {
            name: "osm.mapping.providersrepository.disabled"
            value: true
        }
        PluginParameter {
            name: "osm.mapping.cache.directory"
            value: "osm_cache"
        }
    }

    Map {
        id: mapView
        anchors.fill: parent
        plugin: mapPlugin
        center: QtPositioning.coordinate(44.105878, 9.844382)
        zoomLevel: 10
        focus: true

        Component.onCompleted: {
            console.log("[WMSMapLayer:Component.onCompleted] Propagating base properties from BaseMapLayer to all child layers ...")
            root.mapLayers = [aisTrackMapLayerComponentIstance, docSpaceTrackMapLayerComponentIstance, annotationLayerComponentIstance, staticPoiLayerComponentIstance]
            updateZoomLevels()
        }
        onZoomLevelChanged: updateZoomLevels()

        WheelHandler {
                   acceptedDevices: PointerDevice.Mouse
                   onWheel: (event) => {
                       if (event.angleDelta.y > 0) {
                           mapView.zoomLevel += 1
                       } else if (event.angleDelta.y < 0) {
                           mapView.zoomLevel -= 1
                       }
                       event.accepted = true
                   }
               }

        DrawingArea {
            id: drawingArea
            anchors.fill: parent
            map: mapView
        }

        AISTrackMapLayerComponent { id: aisTrackMapLayerComponentIstance }
        DocSpaceTrackMapLayerComponent { id: docSpaceTrackMapLayerComponentIstance }
        StaticPoiMapLayerComponent { id: staticPoiLayerComponentIstance }
        AnnotationMapLayerComponent { id: annotationLayerComponentIstance }

        TapHandler {
            acceptedButtons: Qt.LeftButton
            gesturePolicy: TapHandler.ReleaseWithinBounds

            onTapped: function (eventPoint) {
                InteractionModeManager.currentSelectedShapeId = ""
                eventPoint.accepted = true
            }
        }
    }

    function updateZoomLevels() {
        for (let layer of root.mapLayers) {
            if (layer && typeof layer.zoomLevel !== "undefined") {
                layer.zoomLevel = mapView.zoomLevel
            }
        }
    }

    TracksSelectionHintDialog {
        id: tracksSelectionHintDialog
    }

    Connections {
        target: LayerManager
        function onAllLayersReady() {
            console.log("Tutti i layer sono pronti! Attivo UI")
            Qt.callLater(() => {
                topToolbar.visible = true
                sidePannel.visible = true
            })

            Qt.callLater(() => {
                PoiOptionsController.fetchAll()
            })

            Qt.callLater(() => {
                tracksSelectionHintDialog.syncInitialTrackStates();
            })
        }
    }

    TopToolbar {
        id: topToolbar
        visible: false
        z: 1000
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 10
    }

    // MapObjectDetailsPanel {
    //     id: objectDetails
    //     width: 300
    //     height: 400
    //     z: 1000
    //     anchors.left: parent.left
    //     anchors.bottom: parent.bottom
    //     anchors.margins: 10
    //     visible: selectedObjects.length > 0
    // }

    ZoomBar {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 20
        z: 1000
        onZoomInRequested: mapView.zoomLevel += 1
        onZoomOutRequested: mapView.zoomLevel -= 1
    }

    SidePannel{
        id: sidePannel
    }

    InsertPoiPopup {
        id: insertPoiPopup
    }
    RectanglePoiPopup {
        id: areaPoiPopup
        visible: false
    }
    EllipsePoiPopup {
        id: ellipsePoiPopup
        visible: false
    }
    PolygonPoiPopup {
        id: polygonPoiPopup
        visible: false
    }

    PointPoiInsertHandler {}
    RectanglePoiInsertHandler {}
    EllipsePoiInsertHandler {}
    PolygonPoiInsertHandler {}

    ShapePopup {
        id: shapePopup
        title: root.createShapeText
        visible: false
    }

    RectangleCreateHandler {}
    EllipseCreateHandler {}
    PolylineCreateHandler {}
    PolygonCreateHandler {}

    Connections {
        target: InteractionModeManager
        function onCurrentSelectedShapeIdChanged(selectedId, previousSelectedId) {
            if (selectedId) {
                console.log("SELECTED SHAPE WITH ID:", selectedId)
            } else {
                console.log("UNSELECTED SHAPE WITH ID:", previousSelectedId)
            }
        }
    }

    RadialMenu {
        id: radialMenu
        width: 350
        height: 350

        logoSrc: Qt.resolvedUrl("./ui/assets/fnxt_n.svg")
        logoGlowPulse: true

        onOptionToggledCallback: tracksSelectionHintDialog.handleRadialMenuOptionToggled
    }

    // Automatic retranslation on language change
    Connections {
        target: LanguageController
        function onLanguageChanged() {
            console.log("Language changed signal received - auto-retranslating")
            root.retranslateUi()
        }
        function onLanguageLoadFailed(language, reason) {
            console.error("Language load failed:", language, "-", reason)
        }
    }
}
