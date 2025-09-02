import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

Item {
    id: missionOverviewStep
    implicitHeight: contentLayout.implicitHeight + 48

    ColumnLayout {
        id: contentLayout
        anchors.fill: parent
        anchors.margins: 24
        spacing: 24

        Text { text: "Mission Name (*)"; color: "#fff"; font.pixelSize: 14; font.weight: Font.Medium }
        TextField { id: missionNameField; placeholderText: "Enter mission name"; Layout.fillWidth: true; Layout.preferredHeight: 48 }

        Text { text: "Mission Domain"; color: "#fff"; font.pixelSize: 14; font.weight: Font.Medium }
        ComboBox { Layout.fillWidth: true; Layout.preferredHeight: 48; model: ["Select Domain","Land","Sea","Air","Space"]; currentIndex: 0 }

        Text { text: "Mission Type"; color: "#fff"; font.pixelSize: 14; font.weight: Font.Medium }
        ComboBox { Layout.fillWidth: true; Layout.preferredHeight: 48; model: ["Select Type","Recon","Surveillance","Search & Rescue","Combat","Transport"]; currentIndex: 0 }

        Button { text: "Apply"; Layout.preferredHeight: 40; onClicked: console.log("MissionOverview applied") }

        Item { Layout.fillHeight: true }
    }
}
