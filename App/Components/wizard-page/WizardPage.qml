import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.Language 1.0

Item {
    id: wizardPage
    anchors.fill: parent

    property string title: ""
    property int currentStep: 0
    property int totalSteps: 1
    property string stepTitle: ""
    property bool canGoBack: currentStep > 0
    property bool canGoNext: true
    property bool showCloseButton: true

    readonly property bool isLastStep: currentStep >= totalSteps - 1

    property alias stepLoader: stepLoader

    signal wizardFinished()
    signal wizardCanceled()

    function goToStep(step) {
        if(step >= 0 && step < totalSteps) {
            stepLoader.opacity = 0
            stepChangeTimer.targetStep = step
            stepChangeTimer.start()
        }
    }

    Timer {
        id: stepChangeTimer
        interval: 250
        property int targetStep: 0
        onTriggered: {
            currentStep = targetStep
            stepLoader.opacity = 1
        }
    }

    function goNext() { if(isLastStep) wizardFinished(); else goToStep(currentStep + 1) }
    function goBack() { if(currentStep > 0) goToStep(currentStep - 1) }
    function closeWizard() { wizardCanceled() }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Section Title
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 92
            color: "transparent"

            // Bottom border
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: Theme.colors.text
                opacity: 0.1
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.leftMargin: Theme.spacing.s8
                anchors.rightMargin: Theme.spacing.s8
                anchors.topMargin: Theme.spacing.s6
                anchors.bottomMargin: Theme.spacing.s6
                spacing: Theme.spacing.s4

                // Text and Step Indicator Row
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 422
                    Layout.preferredHeight: Theme.spacing.s6

                    // Step Title Text
                    Text {
                        text: wizardPage.stepTitle
                        color: Theme.colors.text
                        font.family: Theme.typography.familySans
                        font.pixelSize: Theme.typography.fontSize200
                        font.weight: Theme.typography.weightRegular
                        Layout.fillWidth: true
                    }

                    // Step Counter
                    Text {
                        text: String(wizardPage.currentStep + 1).padStart(2,'0') + " / " + String(wizardPage.totalSteps).padStart(2,'0')
                        color: Theme.colors.text
                        font.family: Theme.typography.familyMono
                        font.pixelSize: Theme.typography.fontSize150
                        font.weight: Theme.typography.weightRegular
                    }
                }

                // Progress Bar
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 422
                    Layout.preferredHeight: Theme.spacing.s1
                    spacing: 4

                    Repeater {
                        model: wizardPage.totalSteps
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 4
                            radius: Theme.radius.xs
                            color: Theme.colors.text
                            opacity: index <= wizardPage.currentStep ? 1.0 : 0.1

                            Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                        }
                    }
                }
            }
        }

        // Content area
        ScrollView {
            id: scrollView
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 200
            clip: true

            Loader {
                id: stepLoader
                width: scrollView.width
                height: item ? item.implicitHeight : 0
                asynchronous: true

                Behavior on opacity {
                    NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                }
            }
        }

        // Footer
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 88
            color: "transparent"

            // Top border
            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: Theme.colors.text
                opacity: 0.1
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Theme.spacing.s10
                anchors.rightMargin: Theme.spacing.s10
                anchors.topMargin: Theme.spacing.s6
                anchors.bottomMargin: Theme.spacing.s6
                spacing: 0

                // Back Button
                UI.Button {
                    Layout.preferredWidth: 183
                    Layout.preferredHeight: Theme.spacing.s10
                    variant: UI.ButtonStyles.Ghost
                    enabled: wizardPage.canGoBack
                    radius: Theme.radius.xs
                    onClicked: wizardPage.goBack()

                    Text {
                        anchors.centerIn: parent
                        text: `${TranslationManager.revision}` && qsTr("Back")
                        color: wizardPage.canGoBack ? Theme.colors.text : Theme.colors.textMuted
                        font.family: Theme.typography.familySans
                        font.pixelSize: Theme.typography.fontSize150
                        font.weight: Theme.typography.weightRegular
                    }
                }

                // Next Button
                UI.Button {
                    Layout.preferredWidth: 183
                    Layout.preferredHeight: Theme.spacing.s10
                    variant: UI.ButtonStyles.Primary
                    enabled: wizardPage.canGoNext
                    radius: Theme.radius.xs
                    onClicked: wizardPage.goNext()

                    Text {
                        anchors.centerIn: parent
                        text: `${TranslationManager.revision}` && qsTr("Next")
                        color: Theme.colors.text
                        font.family: Theme.typography.familySans
                        font.pixelSize: Theme.typography.fontSize150
                        font.weight: Theme.typography.weightRegular
                    }
                }
            }
        }
    }
}
