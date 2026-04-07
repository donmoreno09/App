import QtQuick

import App.Themes 1.0
import App.Features.Map 1.0

Item {
    id: root

    enum Domain { Cruise, Cargo, Land }
    enum Theme { Light, Dark }
    enum Severity { Neutral, Success, Caution, Error }
    enum Motion { Moving, Stationary }
    enum UI { Default, Hover, Selected, Disabled }

    readonly property string baseUrl: "qrc:/App/assets/icons/tracks"

    required property int domain
    property int theme: MapController._currentPlugin.isDark ? TrackIcon.Dark : TrackIcon.Light
    // Depending on ui state, severity and motion might not be needed
    property int severity
    property int motion
    required property int ui

    property string labelText: ""
    required property real heading
    property real baseRotationDeg: 0

    signal tapped()
    signal hoverChanged(bool hovered)
    property alias hovered: hoverHandler.hovered

    readonly property real _zoomLevel: MapController.map ? MapController.map.zoomLevel : 8
    readonly property real _size: Math.min(Math.max(Theme.spacing.s10 - (_zoomLevel - 8) * 5, Theme.spacing.s8), Theme.spacing.s10)

    width: root._size
    height: root._size

    Image {
        anchors.fill: parent
        sourceSize.width: width
        sourceSize.height: height
        source: root._resolveUrl()
        fillMode: Image.PreserveAspectFit
        smooth: true
        rotation: baseRotationDeg + heading - (MapController.map ? MapController.map.bearing : 0)
    }

    Rectangle {
        id: labelBubble
        visible: root.labelText !== ""

        anchors.top: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        color: Theme.colors.transparent

        width: Math.min(Theme.spacing.s16, Math.max(root.width, label.implicitWidth + 8))
        height: label.implicitHeight + 8

        Text {
            id: label

            anchors.fill: parent
            anchors.margins: 4

            text: root.labelText
            font.pixelSize: Theme.typography.fontSize125
            color: MapController._currentPlugin.isDark ? Theme.colors.white : Theme.colors.black

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            maximumLineCount: 1
            elide: Text.ElideRight
        }
    }

    TapHandler {
        acceptedButtons: Qt.LeftButton
        gesturePolicy: TapHandler.ReleaseWithinBounds
        onTapped: root.tapped()
    }

    HoverHandler {
        id: hoverHandler
        onHoveredChanged: root.hoverChanged(hovered)
    }

    function _resolveUrl(): string {
        let domain
        let theme
        let severity
        let motion
        let ui

        switch (root.domain) {
        case TrackIcon.Cruise: domain = "cruise"; break
        case TrackIcon.Cargo: domain = "cargo"; break
        case TrackIcon.Land: domain = "land"; break
        }

        switch (root.theme) {
        case TrackIcon.Light: theme = "light"; break
        case TrackIcon.Dark:
        default: theme = "dark"
        }

        if (root.ui === TrackIcon.Disabled) {
            return `${root.baseUrl}/${domain}/${domain}-disabled-${theme}.svg`
        }

        switch (root.severity) {
        case TrackIcon.Success: severity = "success"; break
        case TrackIcon.Caution: severity = "caution"; break
        case TrackIcon.Error: severity = "error"; break
        case TrackIcon.Neutral:
        default: severity = "neutral"
        }

        switch (root.motion) {
        case TrackIcon.Moving: motion = "sailing"; break
        case TrackIcon.Stationary:
        default: motion = "stationary"
        }

        switch (root.ui) {
        case TrackIcon.Default: ui = "default"; break
        case TrackIcon.Hover: ui = "hover"; break
        case TrackIcon.Selected: ui = "selected"; break
        case TrackIcon.Disabled: ui = "disabled"; break
        }

        return `${root.baseUrl}/${domain}/${domain}-${severity}-${motion}-${ui}-${theme}.svg`
    }
}
