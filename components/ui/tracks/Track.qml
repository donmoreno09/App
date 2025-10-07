import QtQuick 2.15
import QtLocation 6.8
import QtPositioning 6.8

import raise.singleton.panelmanager 1.0
import raise.singleton.language 1.0


MapQuickItem {
    id: traceMarker

    // Core model data representing the track
    property var trackData: modelData
    property string trackType: "" // Also referred to as the MQTT topic

    // Geographical positioning
    coordinate: QtPositioning.coordinate(trackData.pos[0], trackData.pos[1])
    // Anchor point centered on the image
    anchorPoint.x: image.width / 2
    anchorPoint.y: image.height / 2

    // Core track-related properties
    property string channel         // TODO: currently hardcoded as "smartport", should be dynamic
    property point  screenPos       // Screen-space position for aligning overlays (e.g. detached panels)
    property var    link            // Reference to linked UI element (e.g. panel or overlay) attached to the track marker
    property var    history         // Track history data (list of coordinate pairs)
    property var    historyPath     // Path to history data (e.g. for SVG, polyline rendering)

    // Aliased dimensions of the track representation
    property alias realWidth: trackRect.width
    property alias realHeight: trackRect.height

    // Movement-related attributes (currently unused)
    property var    heading
    property var    angle

    // Panel state flags
    property bool   opened: false       // Indicates whether a panel is currently attached to the track
    property color  backgroundColor: "transparent"
    property real   backgroundOpacity: 0.5

    // Visual flags
    property double correctionAngle: 0   // Used to offset heading display (if needed)
    property bool   labelVisible: true
    property bool   vectorVisible: true

    // Automatic retranslation properties
    property string trackPrefix: qsTr("T")

    // Auto-retranslate when language changes
    function retranslateUi() {
        trackPrefix = qsTr("T")
    }

    // Signals
    signal detailsReady(var obj, string channel)
    signal detailsClose(var obj, string channel)

    sourceItem: Item {
        id: trackRect
        width: 40
        height: 40
        opacity: trackData.state === 1 ? 0.5 : 1.0

        // COG direction vector (track heading line)
        Rectangle {
            id: cogLine
            width: 2
            height: 40  // Length of the heading vector
            color: "black"
            x: trackRect.width / 2 - width / 2
            y: trackRect.height / 2 - height

            transform: Rotation {
                origin.x: cogLine.width / 2
                origin.y: cogLine.height
                angle: trackData.cog
            }

            visible: vectorVisible
        }

        Image {
            id: image
            anchors.fill: parent
            anchors.centerIn: parent
            source: "../../../assets/icons/track/smartport/" + trackData.code.substring(0,2) + "/" + trackData.code.substring(2,4) + "/" + trackData.code.substring(4,6) + "/" + trackData.code + ".svg"
            fillMode: Image.PreserveAspectFit
            smooth: true
            opacity: trackData.state === 1 ? 0.5 : 1.0
        }

        Text {
            id: trackLabel
            text: traceMarker.trackPrefix + trackData.tracknumber.toString()
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
                console.log("[TrackPanel] Tap event on track marker triggered.");
                trackData.tracktype = traceMarker.trackType;
                PanelManager.openPanel(trackData, traceMarker);
                console.log("[TrackPanel] Panel request dispatched.");
            }
        }
    }

    Component.onCompleted: {
        mapView.addMapItem(traceMarker);
        traceMarker.screenPos = mapView.fromCoordinate(traceMarker.coordinate);
    }

    Component.onDestruction: {
        // console.log("[Track.qml] Marker destroyed");
        mapView.removeMapItem(traceMarker);
    }

    // Automatic retranslation on language change
    Connections {
        target: LanguageController
        function onLanguageChanged() {
            traceMarker.retranslateUi()
        }
    }

    // -- PANEL LINKING ------------------ //

    onLinkChanged: {
        if (traceMarker.link) {
            // Sync anchor point of the linked component with current marker screen position
            traceMarker.link.markerAnchor = traceMarker.screenPos;
            traceMarker.link.visibleChanged.connect(traceMarker.handleLinkVisibleChanged);
        }
    }

    onVisibleChanged: {
        if (visible)
            traceMarker.screenPos = mapView.fromCoordinate(traceMarker.coordinate);
    }

    onCoordinateChanged: updateScreenPos()

    // Sync screen position on map movement
    Connections {
        target: mapView

        function onCenterChanged() {
            updateScreenPos();
        }

        function onZoomLevelChanged() {
            updateScreenPos();
        }
    }

    function handleLinkVisibleChanged() {
        if (traceMarker.link && traceMarker.link.visible)
            traceMarker.link.markerAnchor = traceMarker.screenPos;
    }

    function updateScreenPos() {
        // Only compute screen position if marker is visible and has valid coordinates
        if (visible && traceMarker.coordinate) {
            traceMarker.screenPos = mapView.fromCoordinate(traceMarker.coordinate, false);

            // Update any linked component's anchor point
            if (traceMarker.link)
                traceMarker.link.markerAnchor = traceMarker.screenPos;
        }
    }

    function linkToPanel(link) {
        traceMarker.link = link;
        traceMarker.opened = true;
    }

    function unlinkToPanel() {
        traceMarker.link = null;
        traceMarker.opened = false;
        closeHistory();
    }

    // -- HISTORY HANDLING ------------------ //

    function getHistory () {}
    function loadHistory (path) {}
    function closeHistory () {}
    function relaodHistory () {}
    function updateHistory () {}

    // -- HEADING / MOTION ------------------ //

    function updateHeading() {
        heading = (trackData.vel && vectorVisible) ? (Math.atan2(-trackData.vel[1], trackData.vel[0])) * (180 / Math.PI) : 0.0;
        angle = heading - correctionAngle;
    }

    function adaptVelocity(b) {
        traceMarker.angle = traceMarker.heading - b;
        correctionAngle = b;
    }
}
