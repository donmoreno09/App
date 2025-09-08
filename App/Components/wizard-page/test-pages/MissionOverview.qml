import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import App.Features.Language 1.0

Item {
    id: missionOverviewStep
    implicitHeight: contentLayout.implicitHeight + 48

    ColumnLayout {
        id: contentLayout
        anchors.fill: parent
        anchors.margins: 24
        spacing: 24

        Text { text: (TranslationManager.revision, qsTr("Mission Name (*)")); color: "#fff"; font.pixelSize: 14; font.weight: Font.Medium }
        TextField { id: missionNameField; placeholderText: (TranslationManager.revision, qsTr("Enter mission name")); Layout.fillWidth: true; Layout.preferredHeight: 48 }

        Text { text: (TranslationManager.revision, qsTr("Mission Domain")); color: "#fff"; font.pixelSize: 14; font.weight: Font.Medium }
        ComboBox { Layout.fillWidth: true; Layout.preferredHeight: 48; model: [(TranslationManager.revision, qsTr("Select Domain")),(TranslationManager.revision, qsTr("Land")),(TranslationManager.revision, qsTr("Sea")),(TranslationManager.revision, qsTr("Air")),(TranslationManager.revision, qsTr("Space"))]; currentIndex: 0 }

        Text { text: (TranslationManager.revision, qsTr("Mission Type")); color: "#fff"; font.pixelSize: 14; font.weight: Font.Medium }
        ComboBox { Layout.fillWidth: true; Layout.preferredHeight: 48; model: [(TranslationManager.revision, qsTr("Select Type")),(TranslationManager.revision, qsTr("Recon")),(TranslationManager.revision, qsTr("Surveillance")),(TranslationManager.revision, qsTr("Search & Rescue")),(TranslationManager.revision, qsTr("Combat")),(TranslationManager.revision, qsTr("Transport"))]; currentIndex: 0 }

        Button { text: (TranslationManager.revision, qsTr("Apply")); Layout.preferredHeight: 40; onClicked: console.log("MissionOverview applied") }

        Item { Layout.fillHeight: true }
    }
}
