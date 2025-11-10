import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import App.Features.SidePanel 1.0
import App.Features.ViGateServices 1.0
import App.Features.Language 1.0

PanelTemplate {
    title.text: (TranslationManager.revision, qsTr("Gate Transits"))
    clip: true

    // Debug
    Component.onCompleted: {
        console.log("=== ViGatePanel Initial ===")
        console.log("  width:", width)
        console.log("  height:", height)
        console.log("=== PanelTemplate ===")
                console.log("  x:", x)
                console.log("  y:", y)
                console.log("  width:", width)
                console.log("  clip:", clip)
    }

    onWidthChanged: {
        console.log("ViGatePanel width changed:", width)
        if (width > 490) {
            console.warn("⚠️ PANEL EXPANDED BEYOND 490px!")
        }
    }

    ScrollView {
        width: parent.width
        height: parent.height
        contentWidth: availableWidth
        clip: true

        // Debug
        Component.onCompleted: {
            console.log("=== ScrollView Initial ===")
            console.log("  width:", width)
            console.log("  contentWidth:", contentWidth)
            console.log("  availableWidth:", availableWidth)
            console.log("=== ScrollView ===")
            console.log("  x:", x)
                    console.log("  clip:", clip)
                    console.log("  contentItem.clip:", contentItem.clip)
        }

        onWidthChanged: {
            console.log("ScrollView width changed:", width)
        }

        ViGateContent {
            width: parent.width
            controller: ViGateController

            // Debug
            Component.onCompleted: {
                console.log("=== ViGateContent Initial ===")
                console.log("  width:", width)
                console.log("  parent.width:", parent ? parent.width : "no parent")
            }

            onWidthChanged: {
                console.log("ViGateContent width changed:", width)
            }
        }
    }
}
