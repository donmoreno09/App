import QtQuick 6.8
import QtQuick.Layouts 6.8
import QtQuick.Controls 6.8

import App.Features.ViGateServices 1.0

Item {
    anchors.fill: parent

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        SummaryCard { Layout.fillWidth: true }
        VehiclesTable { Layout.fillWidth: true }
        PedestriansTable { Layout.fillWidth: true }
    }
}
