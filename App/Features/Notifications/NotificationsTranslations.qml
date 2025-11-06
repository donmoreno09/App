pragma Singleton

import QtQuick 6.8
import App.Features.Language 1.0

QtObject {
    id: root

    // Issue Types Translation
    function getIssueTypeName(typeId) {
        switch(typeId) {
            case 1: return (TranslationManager.revision, qsTr("Incident"))
            case 2: return (TranslationManager.revision, qsTr("Problem with the goods"))
            case 3: return (TranslationManager.revision, qsTr("Collision"))
            case 4: return (TranslationManager.revision, qsTr("Delay"))
            default: return (TranslationManager.revision, qsTr("Unknown"))
        }
    }

    // Solution Types Translation
    function getSolutionTypeName(typeId) {
        switch(typeId) {
            case 1: return (TranslationManager.revision, qsTr("Operation Canceled"))
            case 2: return (TranslationManager.revision, qsTr("Rescheduled"))
            case 3: return (TranslationManager.revision, qsTr("Other"))
            default: return (TranslationManager.revision, qsTr("Unknown"))
        }
    }

    // Operation State Translation
    function getOperationStateName(state) {
        switch(state) {
            case "BLOCKED": return (TranslationManager.revision, qsTr("Blocked"))
            case "ACTIVE": return (TranslationManager.revision, qsTr("Active"))
            case "WARNING": return (TranslationManager.revision, qsTr("Warning"))
            default: return state
        }
    }
}
