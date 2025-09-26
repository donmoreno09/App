/*!
    \qmltype Overlay
    \inqmlmodule App.Components
    \brief Simple, essential overlay component for modals and dialogs.

    Minimal overlay implementation focusing on core functionality:
    - Modal behavior with backdrop
    - Center positioning
    - ESC key and click-outside dismissal
    - Smooth animations
    - Theme integration

    Usage:
    \code
    UI.Overlay {
        id: dialog
        width: 400
        height: 300

        Rectangle {
            anchors.fill: parent
            color: Theme.colors.surface
            radius: Theme.radius.lg

            // Your content here
        }
    }
    \endcode
*/

import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Effects
import App.Themes 1.0

Popup {
    id: root

    property bool showBackdrop: true

    modal: true
    focus: true
    anchors.centerIn: Overlay.overlay
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    Overlay.modal: showBackdrop ? backdropComponent : null

    Component {
        id: backdropComponent

        MultiEffect {
            source: ShaderEffectSource {
                sourceItem: (Overlay.overlay && Overlay.overlay.parent) ? Overlay.overlay.parent : null
                live: true
                hideSource: false
            }

            blurEnabled: true
            blur: 0.6
            autoPaddingEnabled: false
        }
    }

    enter: Transition {
        ParallelAnimation {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200 }
            NumberAnimation { property: "scale"; from: 0.9; to: 1.0; duration: 200 }
        }
    }

    exit: Transition {
        ParallelAnimation {
            NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 150 }
            NumberAnimation { property: "scale"; from: 1.0; to: 0.9; duration: 150 }
        }
    }
}
