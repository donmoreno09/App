import QtQuick 2.15
import QtLocation 6.8
import QtPositioning 6.8

import raise.singleton.panelmanager 1.0


MapQuickItem {
    id: traceMarker

    // Qui la proprità di base che contiene il modello della traccia.
    property var trackData: modelData

    // Positioning in coordinates
    coordinate: QtPositioning.coordinate(trackData.pos[0], trackData.pos[1])
    // anchorPoint x,y based on image center
    anchorPoint.x: image.width / 2
    anchorPoint.y: image.height / 2


    // Qui le proprietà core della traccia
    property string channel         // TODO: for now is smartport but needs to be changed.
    property point  screenPos       // Screen position used for showing panel on screen detached from map.
    property var    link            // In pratica il pannello dei dettagli (o un altro overlay) che deve “seguire” il marker sulla mappa
    property var    history         // La history della traccia, recuperata tramite chiamata od altro.
    property var    historyPath     // Il path della history della traccia

    // Qui proprietà in alias
    property alias realWidth: trackRect.width   // La width / larghezza del sourceItem ossia della traccia
    property alias realHeight: trackRect.height // La height / altezza del sourceItem ossia della traccia

    // Qui le proprietà anatomiche della traccia
    property var    heading             // NOT USING: Direzione di movimento della traccia, derivata dalla velocity
    property var    angle               // NOT USING: Angolatura

    // Qui le proprietà del pannello
    property bool   opened: false   // Opened è relativo al pannello, se è linkato o meno
    property color  backgroundColor: "transparent"
    property real   backgroundOpacity: 0.5

    // Qui altro...
    property double correctionAngle: 0   // NOT USING: correction angle
    property bool   labelVisible: true
    property bool   vectorVisible: true

    // Qui i segnali
    signal detailsReady (var obj, string channel)
    signal detailsClose(var obj, string channel)


    sourceItem: Item {
        id: trackRect
        width: 40
        height: 40


        // Semiretta di orientamento COG
        Rectangle {
            id: cogLine
            width: 2
            height: 40  // lunghezza della semiretta
            color: "black"
            x: trackRect.width / 2 - width / 2  // centrata orizzontalmente
            y: trackRect.height / 2 - height    // parte dal centro verticale e si estende verso l'alto

            transform: Rotation {
                origin.x: cogLine.width / 2
                origin.y: cogLine.height       // ruota intorno al punto di origine in basso
                angle: trackData.cog
            }

            visible: vectorVisible
        }

        Image {
            id: image
            anchors.fill: parent
            anchors.centerIn: parent
            source: "../../../assets/icons/track/smartport/"+trackData.code.substring(0,2)+"/"+trackData.code.substring(2,4)+"/"+trackData.code.substring(4,6)+"/"+trackData.code+".svg"
            fillMode: Image.PreserveAspectFit
            smooth: true
            opacity: trackData.state === 1 ? 0.5 : 1.0
        }

        Text {
            id: trackLabel
            text: "T"+qsTr(trackData.tracknumber.toString())
            font.pixelSize: 12
            color: "black"
            anchors.left: parent.right
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            wrapMode: Text.Wrap
            visible: labelVisible
        }

        TapHandler {
            id: tapHandler
            acceptedButtons: Qt.LeftButton
            gesturePolicy: TapHandler.WithinBounds
            grabPermissions: PointerHandler.CanTakeOverFromAnything
            onTapped: {
                console.log("[TrackPanel] TapHandler tapped on track!")
                PanelManager.openPanel(trackData, traceMarker)
                console.log("[TrackPanel] post")
            }
        }
    }

    Component.onCompleted: {
        console.log("[Track.qml] istanziato, tracknumber: " + trackData.tracknumber)
        mapView.addMapItem(traceMarker)
        traceMarker.screenPos = mapView.fromCoordinate(traceMarker.coordinate)
        // Se è Nan entrambi significa che è fuori schermo.
        console.log("[Track.qml] screen position: ", traceMarker.screenPos.toString())
    }

    Component.onDestruction: {
        console.log("[Track.qml] distrutto")
        mapView.removeMapItem(traceMarker)
    }

    // -- LINK AREA ------------------ //

    onLinkChanged: {
        if (traceMarker.link) {
             // Setto il punto di ancoraggio dalla screen position del marker
            traceMarker.link.markerAnchor = traceMarker.screenPos
             // Connetto dei segnali per il sync sulla visibilità
            traceMarker.link.visibleChanged.connect(traceMarker.handleLinkVisibleChanged)
        }
    }

    onVisibleChanged: {
        if (visible)
            traceMarker.screenPos = mapView.fromCoordinate(traceMarker.coordinate)
    }

    // Quando la coordinate cambia (es. nuovo burst MQTT)
    onCoordinateChanged: updateScreenPos()

    // Quando la mappa cambia centro o livello di zoom
    Connections {
        target: mapView

        function onCenterChanged() {
            updateScreenPos()
        }

        function onZoomLevelChanged() {
            updateScreenPos()
        }
    }


    function handleLinkVisibleChanged()
    {
        // Se la traccia ha un pannello linkato ed è visibile
        if (traceMarker.link && traceMarker.link.visible)
            // setto il punto di ancoraggio dalla screen position del marker
            traceMarker.link.markerAnchor = traceMarker.screenPos
    }

    function updateScreenPos() {
        // Esegue l’aggiornamento solo se il marker è visibile e la sua proprietà coordinate è valida
        if (visible && traceMarker.coordinate) {
            // Il secondo argomento false disattiva il clipping:
            // la funzione restituisce comunque un punto valido anche se la posizione è fuori dal viewport
            traceMarker.screenPos = mapView.fromCoordinate(traceMarker.coordinate, false)

            // Se esiste un oggetto collegato (link),
            // per esempio una linea o un pannello che deve “agganciarsi” al marker,
            // ne aggiorna la proprietà markerAnchor con le nuove coordinate-pixel.
            if(traceMarker.link)
                traceMarker.link.markerAnchor = traceMarker.screenPos
        }
    }

    function linkToPanel(link) {
        traceMarker.link = link
        traceMarker.opened = true
    }

    function unlinkToPanel() {
        traceMarker.link = null
        traceMarker.opened = false
        closeHistory()
    }

    // -- HISTORY AREA ------------------ //

    function getHistory () {}
    function loadHistory (path) {}
    function closeHistory () {}
    function relaodHistory () {}
    function updateHistory () {}

    // -- TRACK MOVEMENT AREA ----------- //

    function updateHeading() {
        heading = (trackData.vel && vectorVisible) ? (Math.atan2(-trackData.vel[1],trackData.vel[0]))* (180/Math.PI) : 0.0
        angle = heading-correctionAngle
    }

    function adaptVelocity(b) {
      traceMarker.angle= traceMarker.heading-b
        correctionAngle=b;
    }
}
