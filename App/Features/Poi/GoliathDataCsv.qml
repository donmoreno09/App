import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.Poi 1.0

UI.FloatingWindow {
    id: root

    width: 1200
    height: 740
    visible: true
    windowTitle: "CSV Viewer"

    property var parentWindow: null
    readonly property string title: windowTitle


    property int deviceAddressColumn: -1

    windowWidth: parentWindow ? parentWindow.width : 1200
    windowHeight: parentWindow ? parentWindow.height : 740

    CsvTableModel {
        id: csv
        onHeaderChanged: {
            deviceAddressColumn = csv.findColumn("Device Address")
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.spacing.s2
        anchors.margins: Theme.spacing.s2

        HorizontalHeaderView {
            Layout.fillWidth: true
            syncView: table
        }

        TableView {
            id: table
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: csv
            clip: true
            interactive: true
            columnSpacing: 8
            rowSpacing: 2
            boundsBehavior: Flickable.StopAtBounds
            reuseItems: true
            selectionMode: TableView.SelectionDisabled

            delegate: Item {
                required property int column
                required property string display

                implicitHeight: 28
                implicitWidth: Math.max(100, textItem.implicitWidth + 16)

                Rectangle {
                    anchors.fill: parent
                    color: (TableView.row % 2 === 0) ? "#222222" : "#333333"
                    radius: 2
                }

                Label {
                    id: textItem
                    anchors.fill: parent
                    anchors.margins: 6
                    text: (root.deviceAddressColumn >= 0 && column === root.deviceAddressColumn)
                          ? "XX.XX.XX.XX"
                          : display
                    color: "lightgray"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    elide: Text.ElideRight
                }
            }
        }
    }

    BusyIndicator {
        anchors.centerIn: parent
        running: csv.loading
        visible: running
    }

    property url csvSource: "qrc:/App/assets/resources/Export_MH3_Goliath.csv"
    Component.onCompleted: csv.load(csvSource, ["EntityName"])
}
