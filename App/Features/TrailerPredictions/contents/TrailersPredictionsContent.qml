import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import Qt5Compat.GraphicalEffects

import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.Language 1.0
import App.Features.TrailerPredictions 1.0

ColumnLayout {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true

    required property TrailerPredictionController controller

    // Loading Indicator
    BusyIndicator {
        Layout.alignment: Qt.AlignCenter
        Layout.topMargin: 300
        running: controller.isLoading
        visible: controller.isLoading
        layer.enabled: true
        layer.effect: ColorOverlay { color: Theme.colors.text }
    }

    UI.Input {
        id: trailerIdInput
        visible: !controller.isLoading
        variant: UI.InputStyles.Success
        Layout.fillWidth: true
        Layout.margins: 10
        labelText: `${TranslationManager.revision}` && qsTr("Trailer ID")
        placeholderText: `${TranslationManager.revision}` && qsTr("Enter ID")
        textField.inputMethodHints: Qt.ImhDigitsOnly
        textField.horizontalAlignment: TextInput.AlignHCenter
        textField.validator: IntValidator { bottom: 1 }
    }

    UI.Button {
        id: fetchButton
        visible: !controller.isLoading
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredHeight: Theme.spacing.s10
        Layout.topMargin: Theme.spacing.s1
        Layout.leftMargin: 10
        Layout.rightMargin: 10
        variant: UI.ButtonStyles.Primary
        text: `${TranslationManager.revision}` && qsTr("Calculate Prediction")
        enabled: trailerIdInput.text && !controller.isLoading

        onClicked: {
            Qt.inputMethod.commit()
            controller.fetchPredictionByTrailerId(parseInt(trailerIdInput.text))
        }
    }

    // Results Section
    ColumnLayout {
        visible: !controller.isLoading && controller.prediction !== -1
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: Theme.spacing.s3
        spacing: Theme.spacing.s3

        StatCard {
            Layout.fillWidth: true
            Layout.leftMargin: 10
            Layout.rightMargin: 10
            icon: "qrc:/App/assets/icons/compass.svg"
            title: `${TranslationManager.revision}` && qsTr("Estimated Time")
            value: formatMinutes(controller.prediction)
        }

        Text {
            text: getStatusText(controller.prediction)
            color: Theme.colors.text
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            Layout.leftMargin: Theme.spacing.s4
            Layout.rightMargin: Theme.spacing.s4
            horizontalAlignment: Text.AlignHCenter
            font {
                family: Theme.typography.bodySans25Family
                pointSize: Theme.typography.bodySans25Size
                weight: Theme.typography.bodySans25Weight
            }
        }
    }


    // Error Message
    Text {
        visible: !controller.isLoading && !controller.hasPrediction && trailerIdInput.text && controller.hasError
        text: `${TranslationManager.revision}` && qsTr("No data available")
        color: Theme.colors.error
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: Theme.spacing.s4
        font {
            family: Theme.typography.bodySans25Family
            pointSize: Theme.typography.bodySans25Size
            weight: Theme.typography.bodySans25Weight
        }
    }

    UI.VerticalSpacer {}

    function formatMinutes(minutes) {
        if (minutes === 0) return `${TranslationManager.revision}` && qsTr("Ready")
        if (minutes < 60) return minutes + `${TranslationManager.revision}` && qsTr(" min")

        const hours = Math.floor(minutes / 60)
        const mins = minutes % 60

        if (mins === 0) {
            return hours + (hours > 1 ?
                `${TranslationManager.revision}` && qsTr(" hours") :
                `${TranslationManager.revision}` && qsTr(" hour"))
        }
        return hours + "h " + mins + "min"
    }

    function getStatusText(minutes) {
        if (minutes === 0) return `${TranslationManager.revision}` && qsTr("Immediate access to the bay")
        if (minutes < 30) return `${TranslationManager.revision}` && qsTr("Short wait - entry soon")
        if (minutes < 120) return `${TranslationManager.revision}` && qsTr("In queue - moderate wait")
        return `${TranslationManager.revision}` && qsTr("Extended wait - consider alternatives")
    }
}
