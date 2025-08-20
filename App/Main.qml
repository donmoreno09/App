import QtQuick
import QtQuick.Controls.Fusion
import QtQuick.Controls

import App.Themes 1.0
import App.Tests 1.0 as UI
// import App.Components 1.0

ApplicationWindow {
    width: 640
    height: 480
    visible: true
    title: qsTr("Theming System")

    background: Rectangle {
        color: Theme.colors.background
    }

    ScrollView {
        anchors.fill: parent
        UI.IconButtonsTest{}
    }

    // SampleButton { }

    // Column {
    //     anchors.centerIn: parent
    //     spacing: Theme.spacing.s4

    //     Item {
    //         width: 220
    //         height: 140
    //         z: Theme.elevation.raised

    //         // Border
    //         Rectangle {
    //             anchors.fill: parent
    //             radius: Theme.radius.md
    //             color: Theme.colors.surface
    //             border.width: Theme.borders.b2
    //             border.color: Theme.colors.textMuted

    //             Text {
    //                 anchors.centerIn: parent
    //                 text: "Hover me"
    //                 color: Theme.colors.text
    //                 font.family: Theme.typography.familySans
    //             }
    //         }

    //         // Outline ring (helper computes offset so there's no gap)
    //         Rectangle {
    //             anchors.fill: parent
    //             color: "transparent"
    //             anchors.margins: -Theme.borders.offset2 // expand outward
    //             border.width: Theme.borders.outline2
    //             radius: Theme.radius.md + Theme.borders.outline2
    //             border.color: Theme.colors.primary
    //             visible: hoverArea.containsMouse
    //         }

    //         // Hover detection
    //         MouseArea {
    //             id: hoverArea
    //             anchors.fill: parent
    //             hoverEnabled: true
    //             acceptedButtons: Qt.NoButton // hover only
    //         }
    //     }

    //     Button {
    //         contentItem: Text {
    //             text: "Change Theme"
    //             color: Theme.colors.primaryText
    //             font.family: Theme.typography.familyMono
    //         }

    //         background: Rectangle {
    //             color: Theme.colors.primary
    //             radius: Theme.radius.sm
    //         }

    //         onClicked: Theme.setTheme(Theme.currentVariant === Themes.Fincantieri ? Themes.FincantieriLight : Themes.Fincantieri)
    //     }
    // }
}
