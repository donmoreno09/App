import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.Language 1.0

ColumnLayout {
    id: root
    spacing: Theme.spacing.s4

    readonly property var selectedLayers: {
        var layers = []
        if (aisToggle.checked) layers.push("ais")
        if (docSpaceToggle.checked) layers.push("docSpace")
        if (tirToggle.checked) layers.push("tir")
        return layers
    }

    readonly property bool isValid: selectedLayers.length > 0

    function setLayers(layers) {
        aisToggle.checked = layers.includes("ais")
        docSpaceToggle.checked = layers.includes("docSpace")
        tirToggle.checked = layers.includes("tir")
    }

    RowLayout {
        Layout.fillWidth: true
        Label {
            Layout.fillWidth: true
            text: `${TranslationManager.revision}` && qsTr("AIS")
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
            text: `${TranslationManager.revision}` && qsTr("DOC - SPACE")
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
            text: `${TranslationManager.revision}` && qsTr("TRUCK")
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
}
