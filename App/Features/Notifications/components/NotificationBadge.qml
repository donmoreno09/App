import QtQuick 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Features.Language 1.0

Rectangle {
    id: root

    required property string operationState

    Layout.preferredWidth: Theme.spacing.s20
    Layout.preferredHeight: Theme.spacing.s6
    radius: Theme.radius.sm
    color: {
        if (operationState === "BLOCKED") return Theme.colors.warning500
        if (operationState === "ACTIVE") return Theme.colors.success500
        return Theme.colors.caution500
    }

    Text {
        anchors.centerIn: parent
        text: {
            if (root.operationState === "BLOCKED") return `${TranslationManager.revision}` && qsTr("NEW")
            if (root.operationState === "ACTIVE") return `${TranslationManager.revision}` && qsTr("UPDATED")
            return ""
        }
        color: Theme.colors.text
        font.family: Theme.typography.bodySans15Family
        font.pointSize: Theme.typography.bodySans15Size
        font.weight: Theme.typography.bodySans15StrongWeight
    }
}
