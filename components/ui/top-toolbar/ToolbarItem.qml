import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import Qt5Compat.GraphicalEffects

import "./utils.js" as ToolbarUtils

ToolButton {
    id: toolBtn

    property TopToolbar toolbar
    property var tool

    implicitWidth: 36
    implicitHeight: 36

    // ORIGINALE BACKGROUND
    // background: Rectangle {
    //     color: {
    //         if (toolBtn.hovered) return "#aabcda"
    //         if (tool.id === toolbar.currentToolId || tool.id === toolbar.currentMode) return "#bfcbde"
    //         return "transparent"
    //     }
    //     radius: 6
    // }

    background: Rectangle {
        radius: 4
        color: toolBtn.checked ? "#FFFFFF" : "transparent"
        border.color: toolBtn.hovered ? "#404040" : "transparent"
        border.width: toolBtn.hovered ? 1 : 0

        Behavior on color { ColorAnimation { duration: 100 } }
        Behavior on border.color { ColorAnimation { duration: 100 } }
    }

    contentItem: Item {
        anchors.fill: parent

        Image {
            id: iconImage
            source: tool.icon
            // ORIGINALE DIMENSIONAMENTO ICONA
            // width: 16
            // height: 16
            // anchors.centerIn: parent
            // fillMode: Image.PreserveAspectFit

            anchors.fill: parent
            anchors.margins: 6
            fillMode: Image.PreserveAspectFit
            smooth: true
            antialiasing: true

            ColorOverlay {
                anchors.fill: parent
                source: iconImage
                color: toolBtn.checked ? "#000000" : "#FFFFFF"
                visible: true
            }

            Glow {
                id: iconGlowEffect
                source: iconImage
                anchors.fill: iconImage
                color: "#5281c6f0"
                radius: 0
                visible: false
            }
        }

        Text {
            id: toolIndexText
            text: ToolbarUtils.getToolIndex(toolbar.toolsModel, tool)
            font.pixelSize: 8
            // ORIGINALE COLORE TESTO
            // color: "#555"

            // Rimosso: Behavior on color { ColorAnimation { duration: 150 } } (per risolvere il problema del colore iniziale)
            color: toolBtn.checked ? "#000000" : (toolBtn.hovered ? "#FFFFFF" : "#CCCCCC")
            font.family: "RobotoRegular"

            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.rightMargin: 4
            anchors.bottomMargin: 2
        }
    }

    onPressed: {
        toolbar.setCurrentTool(tool.id)

        if (tool && !tool.menu) toolbar.previousToolId = toolbar.currentToolId
    }

    states: [
        State {
            name: "checkedState"
            when: toolBtn.checked
            PropertyChanges { target: iconGlowEffect; visible: true; radius: 8 }
            PropertyChanges { target: toolIndexText; color: "#000000"; font.bold: true }
        },
        State {
            name: "hoveredState"
            when: toolBtn.hovered && !toolBtn.checked
            PropertyChanges { target: toolBtn.background; border.color: "#404040"; border.width: 1 }
            PropertyChanges { target: iconImage.children[0]; color: "#FFFFFF" }
            PropertyChanges { target: toolIndexText; color: "#FFFFFF" }
        },
        State {
            name: "defaultState"
            when: !toolBtn.hovered && !toolBtn.checked
            PropertyChanges { target: iconGlowEffect; visible: false; radius: 0 }
            PropertyChanges { target: toolIndexText; color: "#CCCCCC"; font.bold: false }
        }
    ]

    transitions: [
        Transition {
            from: "*"
            to: "checkedState"
            ParallelAnimation {
                ColorAnimation { target: toolBtn.background; properties: "color"; duration: 150 }
                ColorAnimation { target: iconImage.children[0]; properties: "color"; duration: 150 }
                ColorAnimation { target: toolIndexText; properties: "color"; duration: 150 }
                NumberAnimation { target: iconGlowEffect; properties: "radius"; duration: 150 }
            }
        },
        Transition {
            from: "checkedState"
            to: "defaultState"
            ParallelAnimation {
                ColorAnimation { target: toolBtn.background; properties: "color"; duration: 150 }
                ColorAnimation { target: iconImage.children[0]; properties: "color"; duration: 150 }
                ColorAnimation { target: toolIndexText; properties: "color"; duration: 150 }
                NumberAnimation { target: iconGlowEffect; properties: "radius"; duration: 150 }
            }
        },
        Transition {
            from: "*"
            to: "hoveredState"
            ColorAnimation { target: toolBtn.background; properties: "border.color,border.width"; duration: 100 }
            ColorAnimation { target: iconImage.children[0]; properties: "color"; duration: 100 }
            ColorAnimation { target: toolIndexText; properties: "color"; duration: 100 }
        },
        Transition {
            from: "hoveredState"
            to: "defaultState"
            ColorAnimation { target: toolBtn.background; properties: "border.color,border.width"; duration: 100 }
            ColorAnimation { target: iconImage.children[0]; properties: "color"; duration: 100 }
            ColorAnimation { target: toolIndexText; properties: "color"; duration: 100 }
        }
    ]
}
