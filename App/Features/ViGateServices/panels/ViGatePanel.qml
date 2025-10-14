import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import App.Features.SidePanel 1.0
import App.Features.ViGateServices 1.0

PanelTemplate {
    title.text: qsTr("Gate Services")

    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth
        clip: true
        ViGateContent { anchors.fill: parent }
    }
}
