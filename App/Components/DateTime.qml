/*!
    \qmltype DateTime
    \inqmlmodule App.Components
    \brief Real-time date/time display component showing both UTC and local time zones.

    Usage:
    \code
    UI.DateTime {
        anchors.left: parent.left
        anchors.leftMargin: Theme.spacing.s4
        showSeconds: true
    }
    \endcode
*/

import QtQuick 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0

RowLayout {
    id: root
    spacing: Theme.spacing.s2

    property bool showSeconds: true

    QtObject {
        id: d
        property string utcTimeString: ""
        property string localTimeString: ""

        function updateTimeStrings() {
            const now = new Date()

            if (root.showSeconds) {
                utcTimeString = now.toISOString().substr(11, 8)
                localTimeString = now.toLocaleTimeString(Qt.locale(), "hh:mm:ss")
            } else {
                utcTimeString = now.toISOString().substr(11, 5)
                localTimeString = now.toLocaleTimeString(Qt.locale(), "hh:mm")
            }
        }

        Component.onCompleted: updateTimeStrings()
    }

    Timer {
        interval: 300
        repeat: true
        running: root.visible
        onTriggered: d.updateTimeStrings()
    }

    Image {
        source: "qrc:/App/assets/icons/clock.svg"
        width: Theme.icons.sizeLg
        height: Theme.icons.sizeLg
    }

    Text {
        text: "UTC"
        font.family: Theme.typography.familySans
        font.pixelSize: Theme.typography.sizeLg
        font.weight: Theme.typography.weightMedium
        color: Theme.colors.text
        font.letterSpacing: Theme.typography.letterSpacingWide
    }

    Text {
        text: d.utcTimeString
        font.family: Theme.typography.familySans
        font.pixelSize: Theme.typography.sizeLg
        font.weight: Theme.typography.weightMedium
        color: Theme.colors.text
        font.letterSpacing: Theme.typography.letterSpacingWide
    }

    Text {
        text: "LOCAL"
        font.family: Theme.typography.familySans
        font.pixelSize: Theme.typography.sizeLg
        font.weight: Theme.typography.weightMedium
        color: Theme.colors.text
        font.letterSpacing: Theme.typography.letterSpacingWide
    }

    Text {
        text: d.localTimeString
        font.family: Theme.typography.familySans
        font.pixelSize: Theme.typography.sizeLg
        font.weight: Theme.typography.weightMedium
        color: Theme.colors.text
        font.letterSpacing: Theme.typography.letterSpacingWide
    }
}
