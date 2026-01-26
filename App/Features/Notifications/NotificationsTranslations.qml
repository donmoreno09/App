pragma Singleton

import QtQuick 6.8
import App.Features.Language 1.0

QtObject {
    id: root

    // Issue Types Translation
    function getIssueTypeName(issueType) {
        switch(issueType) {
            case "INCIDENT": return `${TranslationManager.revision}` && qsTr("Incident")
            case "PROBLEM_WITH_GOODS": return `${TranslationManager.revision}` && qsTr("Problem with the goods")
            case "COLLISION": return `${TranslationManager.revision}` && qsTr("Collision")
            case "DELAY": return `${TranslationManager.revision}` && qsTr("Delay")
            default: return `${TranslationManager.revision}` && qsTr("Unknown")
        }
    }

    // Solution Types Translation
    function getSolutionTypeName(solutionType) {
        switch(solutionType) {
            case "OPERATION_CANCELED": return `${TranslationManager.revision}` && qsTr("Operation Canceled")
            case "RESCHEDULED": return `${TranslationManager.revision}` && qsTr("Rescheduled")
            case "OTHER": return `${TranslationManager.revision}` && qsTr("Other")
            default: return `${TranslationManager.revision}` && qsTr("Unknown")
        }
    }
}
