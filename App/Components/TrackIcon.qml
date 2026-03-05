import QtQuick

import App.Themes 1.0
import App.Features.Map 1.0

Item {
    id: root

    enum Domain { Cruise, Cargo, Land }
    enum Severity { Neutral, Success, Caution, Error }
    enum Motion { Moving, Stationary }
    enum UI { Default, Hover, Selected, Disabled }

    readonly property string baseUrl: "qrc:/App/assets/icons/tracks"

    required property int domain
    // Depending on ui state, severity and motion might not be needed
    property int severity
    property int motion
    required property int ui


    property string labelText: ""
    required property real heading
    property real baseRotationDeg: 0

    signal tapped()

    width: Theme.spacing.s12
    height: Theme.spacing.s12

    Image {
        anchors.fill: parent
        sourceSize.width: width
        sourceSize.height: height
        source: root._resolveUrl()
        fillMode: Image.PreserveAspectFit
        smooth: true
        rotation: baseRotationDeg + heading - (MapController.map ? MapController.map.bearing : 0)
    }

    Text {
        visible: root.labelText !== ""
        text: root.labelText
        font.pixelSize: 12
        color: MapController._currentPlugin.isDark ? Theme.colors.white : Theme.colors.black
        anchors.top: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.Wrap
    }

    TapHandler {
        acceptedButtons: Qt.LeftButton
        gesturePolicy: TapHandler.ReleaseWithinBounds
        onTapped: root.tapped()
    }

    function _resolveUrl(): string {
        let domain
        let severity
        let motion
        let ui

        switch (root.domain) {
        case TrackIcon.Cruise: domain = "cruise"; break
        case TrackIcon.Cargo: domain = "cargo"; break
        case TrackIcon.Land: domain = "land"; break
        }

        if (root.ui === TrackIcon.Disabled) {
            return `${root.baseUrl}/${domain}/${domain}-disabled.svg`
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

        return `${root.baseUrl}/${domain}/${domain}-${severity}-${motion}-${ui}.svg`
    }
}
