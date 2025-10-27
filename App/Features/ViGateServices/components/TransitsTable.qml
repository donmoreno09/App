import QtQuick 6.8
import QtQuick.Layouts 6.8
import QtQuick.Controls 6.8
import App.Themes 1.0

GroupBox {
    id: root
    title: qsTr("Transits")
    Layout.fillWidth: true
    Layout.fillHeight: true

    required property var model

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacing.s2
        spacing: Theme.spacing.s2

        // Header Row
        Rectangle {
            Layout.fillWidth: true
            height: Theme.spacing.s10
            color: Theme.colors.surface
            radius: Theme.radius.sm
            z: 2

            Flickable {
                id: headerFlickable
                anchors.fill: parent
                contentWidth: headerRow.width
                clip: true

                Row {
                    id: headerRow
                    height: parent.height
                    spacing: 0

                    component HeaderText: Text {
                        required property string headerText
                        required property real headerWidth

                        text: headerText
                        font.family: Theme.typography.familySans
                        font.weight: Theme.typography.weightSemibold
                        color: Theme.colors.text
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        width: headerWidth
                        height: Theme.spacing.s10
                        leftPadding: Theme.spacing.s2
                        rightPadding: Theme.spacing.s2
                    }

                    HeaderText { headerText: qsTr("Gate Name"); headerWidth: 120 }
                    HeaderText { headerText: qsTr("Transit ID"); headerWidth: 200 }
                    HeaderText { headerText: qsTr("Start Date"); headerWidth: 150 }
                    HeaderText { headerText: qsTr("End Date"); headerWidth: 150 }
                    HeaderText { headerText: qsTr("Status"); headerWidth: 120 }
                    HeaderText { headerText: qsTr("Lane Type"); headerWidth: 100 }
                    HeaderText { headerText: qsTr("Lane Status"); headerWidth: 100 }
                    HeaderText { headerText: qsTr("Lane Name"); headerWidth: 120 }
                    HeaderText { headerText: qsTr("Direction"); headerWidth: 100 }
                    HeaderText { headerText: qsTr("Color"); headerWidth: 80 }
                    HeaderText { headerText: qsTr("Macro Class"); headerWidth: 100 }
                    HeaderText { headerText: qsTr("Micro Class"); headerWidth: 100 }
                    HeaderText { headerText: qsTr("Make"); headerWidth: 100 }
                    HeaderText { headerText: qsTr("Model"); headerWidth: 100 }
                    HeaderText { headerText: qsTr("Country"); headerWidth: 80 }
                    HeaderText { headerText: qsTr("Kemler"); headerWidth: 80 }
                    HeaderText { headerText: qsTr("Auth"); headerWidth: 80 }
                    HeaderText { headerText: qsTr("Auth Message"); headerWidth: 150 }
                    HeaderText { headerText: qsTr("Permission Type"); headerWidth: 120 }
                    HeaderText { headerText: qsTr("Vehicle Plate"); headerWidth: 120 }
                    HeaderText { headerText: qsTr("Person Name"); headerWidth: 150 }
                    HeaderText { headerText: qsTr("Company"); headerWidth: 200 }
                }

                // Sync scrolling with ListView below
                Connections {
                    target: listView
                    function onContentXChanged() {
                        headerFlickable.contentX = listView.contentX
                    }
                }
            }
        }

        // Use ListView instead of TableView
        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            model: root.model

            flickableDirection: Flickable.HorizontalAndVerticalFlick
            boundsBehavior: Flickable.StopAtBounds

            // Performance optimizations
            cacheBuffer: Theme.spacing.s10 * 10  // Cache 10 extra rows
            reuseItems: true  // Recycle delegates (crucial!)

            // Smooth scrolling
            maximumFlickVelocity: 2500
            flickDeceleration: 1500

            delegate: Rectangle {
                id: rowDelegate
                width: Math.max(contentRow.width, listView.width)
                height: Theme.spacing.s10
                color: index % 2 === 0 ? Theme.colors.transparent : Theme.colors.surface

                Row {
                    id: contentRow
                    height: parent.height
                    spacing: 0

                    component CellText: Text {
                        required property string cellText
                        required property real cellWidth
                        property color cellColor: Theme.colors.text

                        text: cellText
                        color: cellColor
                        font.family: Theme.typography.familySans
                        font.weight: Theme.typography.weightRegular
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignLeft
                        elide: Text.ElideRight
                        width: cellWidth
                        height: Theme.spacing.s10
                        leftPadding: Theme.spacing.s2
                        rightPadding: Theme.spacing.s2
                    }

                    CellText { cellText: model.gateName || "-"; cellWidth: 120 }
                    CellText { cellText: model.transitId || "-"; cellWidth: 200 }
                    CellText { cellText: model.transitStartDate || "-"; cellWidth: 150 }
                    CellText { cellText: model.transitEndDate || "-"; cellWidth: 150 }
                    CellText {
                        cellText: model.transitStatus || "-"
                        cellWidth: 120
                        cellColor: model.transitStatus === "Autorizzato" ? Theme.colors.success : Theme.colors.error
                        font.weight: Theme.typography.weightMedium
                    }
                    CellText { cellText: model.laneTypeId || "-"; cellWidth: 100 }
                    CellText { cellText: model.laneStatusId || "-"; cellWidth: 100 }
                    CellText { cellText: model.laneName || "-"; cellWidth: 120 }
                    CellText {
                        cellText: model.transitDirection || "-"
                        cellWidth: 100
                        cellColor: model.transitDirection === "IN" ? Theme.colors.success : Theme.colors.warning
                        font.weight: Theme.typography.weightMedium
                    }

                    // Transit Info columns (only for VEHICLE)
                    CellText { cellText: model.hasTransitInfo ? (model.color || "-") : "-"; cellWidth: 80 }
                    CellText { cellText: model.hasTransitInfo ? (model.macroClass || "-") : "-"; cellWidth: 100 }
                    CellText { cellText: model.hasTransitInfo ? (model.microClass || "-") : "-"; cellWidth: 100 }
                    CellText { cellText: model.hasTransitInfo ? (model.make || "-") : "-"; cellWidth: 100 }
                    CellText { cellText: model.hasTransitInfo ? (model.model || "-") : "-"; cellWidth: 100 }
                    CellText { cellText: model.hasTransitInfo ? (model.country || "-") : "-"; cellWidth: 80 }
                    CellText { cellText: model.hasTransitInfo ? (model.kemler || "-") : "-"; cellWidth: 80 }

                    // Permission columns
                    CellText {
                        cellText: model.hasPermission ? (model.auth || "-") : "-"
                        cellWidth: 80
                        cellColor: model.auth === "ACCEPT" ? Theme.colors.success : Theme.colors.error
                    }
                    CellText { cellText: model.hasPermission ? (model.authMessage || "-") : "-"; cellWidth: 150 }
                    CellText { cellText: model.hasPermission ? (model.permissionType || "-") : "-"; cellWidth: 120 }
                    CellText { cellText: model.hasPermission ? (model.vehiclePlate || "-") : "-"; cellWidth: 120 }
                    CellText { cellText: model.hasPermission ? (model.peopleFullname || "-") : "-"; cellWidth: 150 }
                    CellText { cellText: model.hasPermission ? (model.companyFullname || "-") : "-"; cellWidth: 200 }
                }
            }

            ScrollBar.vertical: ScrollBar {
                width: 12
            }

            ScrollBar.horizontal: ScrollBar {
                height: 12
            }
        }
    }
}
