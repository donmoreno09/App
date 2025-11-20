import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI

ColumnLayout {
    id: root
    spacing: Theme.spacing.s4

    readonly property var selectedLayers: {
        var layers = []
        if (aisToggle.checked) layers.push("ais")
        if (docSpaceToggle.checked) layers.push("docSpace")
        if (tirToggle.checked) layers.push("tir")
        if (poiToggle.checked) layers.push("poi")
        return layers
    }

    readonly property bool isValid: selectedLayers.length > 0

    function setLayers(layers) {
        aisToggle.checked = layers.includes("ais")
        docSpaceToggle.checked = layers.includes("docSpace")
        tirToggle.checked = layers.includes("tir")
        poiToggle.checked = layers.includes("poi")
    }

    Label {
        text: qsTr("Layer Selection(*)")
        color: Theme.colors.text
        Layout.leftMargin: Theme.spacing.s3
        font {
            family: Theme.typography.bodySans25Family
            pointSize: Theme.typography.bodySans25Size
            weight: Theme.typography.bodySans25Weight
        }
    }

    UI.HorizontalDivider {}

    RowLayout {
        Layout.fillWidth: true
        Label {
            Layout.fillWidth: true
            text: qsTr("AIS")
            color: Theme.colors.text
            font {
                family: Theme.typography.bodySans25Family
                pointSize: Theme.typography.bodySans25Size
                weight: Theme.typography.bodySans25Weight
            }
        }
        UI.Toggle {
            id: aisToggle
            checked: false
        }
    }

    RowLayout {
        Layout.fillWidth: true
        Label {
            Layout.fillWidth: true
            text: qsTr("DOC - SPACE")
            color: Theme.colors.text
            font {
                family: Theme.typography.bodySans25Family
                pointSize: Theme.typography.bodySans25Size
                weight: Theme.typography.bodySans25Weight
            }
        }
        UI.Toggle {
            id: docSpaceToggle
            checked: false
        }
    }

    RowLayout {
        Layout.fillWidth: true
        Label {
            Layout.fillWidth: true
            text: qsTr("TIR")
            color: Theme.colors.text
            font {
                family: Theme.typography.bodySans25Family
                pointSize: Theme.typography.bodySans25Size
                weight: Theme.typography.bodySans25Weight
            }
        }
        UI.Toggle {
            id: tirToggle
            checked: false
        }
    }

    RowLayout {
        Layout.fillWidth: true
        Label {
            Layout.fillWidth: true
            text: qsTr("PoI")
            color: Theme.colors.text
            font {
                family: Theme.typography.bodySans25Family
                pointSize: Theme.typography.bodySans25Size
                weight: Theme.typography.bodySans25Weight
            }
        }
        UI.Toggle {
            id: poiToggle
            checked: false
        }
    }
}
