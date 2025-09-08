import QtQuick 6.8
import QtQuick.Controls 6.8
import App.Components 1.0
import App.Features.Language 1.0

WizardPage {
    id: testWizard
    title: (TranslationManager.revision, qsTr("Mission Menu"))

    StepDefinitions { id: stepDefs }

    totalSteps: stepDefs.totalSteps
    stepTitle: stepDefs.titles[currentStep] || ""

    Component { id: missionOverviewComp; MissionOverview {} }
    Component { id: operationalAreaComp; OperationalArea {} }

    Component.onCompleted: stepLoader.sourceComponent = getStepComponent(currentStep)
    onCurrentStepChanged: stepLoader.sourceComponent = getStepComponent(currentStep)

    function getStepComponent(step) {
        switch(step) {
        case stepDefs.steps.MISSION_OVERVIEW.index: return missionOverviewComp
        case stepDefs.steps.OPERATIONAL_AREA.index: return operationalAreaComp
        default: return null
        }
    }
}
