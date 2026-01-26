import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI

ColumnLayout {
    id: root
    spacing: Theme.spacing.s4

    readonly property var selectedLayers: {
       var layers = {}
       layers["ais"] = aisToggle.checked
       layers["doc-space"] = docSpaceToggle.checked
       layers["tir"] = tirToggle.checked
       layers["poi"] = poiToggle.checked

        console.log("LayerSelection.selectedLayers:", JSON.stringify(layers))
        return layers
   }

    readonly property bool isValid: {
            const valid = aisToggle.checked || docSpaceToggle.checked ||
                         tirToggle.checked || poiToggle.checked
            console.log("LayerSelection.isValid:", valid)
            return valid
        }

    function setLayers(layersMap) {
        aisToggle.checked = layersMap["ais"] === true
        docSpaceToggle.checked = layersMap["doc-space"] === true
        tirToggle.checked = layersMap["tir"] === true
        poiToggle.checked = layersMap["poi"] === true
    }

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

    UI.HorizontalDivider {}

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

    UI.HorizontalDivider {}

    RowLayout {
        Layout.fillWidth: true
        Label {
            Layout.fillWidth: true
            text: qsTr("TRUCK")
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

    UI.HorizontalDivider {}

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

    UI.HorizontalDivider {}
}
