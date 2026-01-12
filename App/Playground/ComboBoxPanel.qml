import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.Panels 1.0
import App.Features.Language 1.0

PanelTemplate {
    title.text: `${TranslationManager.revision}` && qsTr("ComboBox Test")

    ScrollView {
        id: sv
        anchors.fill: parent

        Frame {
            padding: Theme.spacing.s4
            width: sv.availableWidth

            ColumnLayout {
                anchors.fill: parent
                spacing: Theme.spacing.s4

                // Basic ComboBox
                UI.ComboBox {
                    Layout.fillWidth: true
                    labelText: "Basic ComboBox"
                    model: ["Option 1", "Option 2", "Option 3", "Option 4"]
                }

                // Long list with scroll
                UI.ComboBox {
                    Layout.fillWidth: true
                    labelText: "Countries (Long List)"
                    model: [
                        "Afghanistan", "Albania", "Algeria", "Andorra", "Angola",
                        "Argentina", "Armenia", "Australia", "Austria", "Azerbaijan",
                        "Bahamas", "Bahrain", "Bangladesh", "Barbados", "Belarus",
                        "Belgium", "Belize", "Benin", "Bhutan", "Bolivia",
                        "Bosnia and Herzegovina", "Botswana", "Brazil", "Brunei", "Bulgaria",
                        "Burkina Faso", "Burundi", "Cambodia", "Cameroon", "Canada"
                    ]
                }

                // Preselected value
                UI.ComboBox {
                    Layout.fillWidth: true
                    labelText: "Preselected Value"
                    model: ["January", "February", "March", "April", "May", "June"]
                    currentIndex: 2  // March
                }

                // Disabled ComboBox
                UI.ComboBox {
                    Layout.fillWidth: true
                    enabled: false
                    labelText: "Disabled State"
                    model: ["Cannot", "Select", "These"]
                    currentIndex: 1
                }

                UI.VerticalSpacer { }
            }
        }
    }
}
