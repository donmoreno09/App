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

        ScrollView {
            Layout.fillWidth: true
            Layout.preferredHeight: 200
            clip: true
            ListView {
                id: listView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                model: root.model

                flickableDirection: Flickable.HorizontalAndVerticalFlick
                boundsBehavior: Flickable.StopAtBounds

                // Performance optimizations
                cacheBuffer: Theme.spacing.s10 * 10
                reuseItems: true

                // Smooth scrolling
                maximumFlickVelocity: 2500
                flickDeceleration: 1500

                delegate: Rectangle {
                    // CRITICAL: Define required properties to receive model data
                    required property int index
                    required property string gateName
                    required property string transitId
                    required property string transitStartDate
                    required property string transitEndDate
                    required property string transitStatus
                    required property string laneTypeId
                    required property string laneStatusId
                    required property string laneName
                    required property string transitDirection
                    required property string colors
                    required property string macroClass
                    required property string microClass
                    required property string make
                    required property string models
                    required property string country
                    required property string kemler
                    required property bool hasTransitInfo
                    required property string auth
                    required property string authMessage
                    required property string permissionType
                    required property string vehiclePlate
                    required property string peopleFullname
                    required property string companyFullname
                    required property bool hasPermission

                    width: contentRow.width
                    height: Theme.spacing.s10
                    color: index % 2 === 0 ? Theme.colors.transparent : Theme.colors.surfaceVariant

                    Row {
                        id: contentRow
                        height: parent.height
                        spacing: 0

                        // Gate Name
                        Text {
                            text: gateName || "-"
                            color: Theme.colors.text
                            font.family: Theme.typography.familySans
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            elide: Text.ElideRight
                            width: 120
                            height: Theme.spacing.s10
                            leftPadding: Theme.spacing.s2
                            rightPadding: Theme.spacing.s2
                        }

                        // Transit ID
                        Text {
                            text: transitId || "-"
                            color: Theme.colors.text
                            font.family: Theme.typography.familySans
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            elide: Text.ElideRight
                            width: 200
                            height: Theme.spacing.s10
                            leftPadding: Theme.spacing.s2
                            rightPadding: Theme.spacing.s2
                        }

                        // Start Date
                        Text {
                            text: transitStartDate || "-"
                            color: Theme.colors.text
                            font.family: Theme.typography.familySans
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            elide: Text.ElideRight
                            width: 150
                            height: Theme.spacing.s10
                            leftPadding: Theme.spacing.s2
                            rightPadding: Theme.spacing.s2
                        }

                        // End Date
                        Text {
                            text: transitEndDate || "-"
                            color: Theme.colors.text
                            font.family: Theme.typography.familySans
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            elide: Text.ElideRight
                            width: 150
                            height: Theme.spacing.s10
                            leftPadding: Theme.spacing.s2
                            rightPadding: Theme.spacing.s2
                        }

                        // Status
                        Text {
                            text: transitStatus || "-"
                            color: transitStatus === "Autorizzato" ? Theme.colors.success : Theme.colors.error
                            font.family: Theme.typography.familySans
                            font.weight: Theme.typography.weightMedium
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            elide: Text.ElideRight
                            width: 120
                            height: Theme.spacing.s10
                            leftPadding: Theme.spacing.s2
                            rightPadding: Theme.spacing.s2
                        }

                        // Lane Type
                        Text {
                            text: laneTypeId || "-"
                            color: Theme.colors.text
                            font.family: Theme.typography.familySans
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            elide: Text.ElideRight
                            width: 100
                            height: Theme.spacing.s10
                            leftPadding: Theme.spacing.s2
                            rightPadding: Theme.spacing.s2
                        }

                        // Lane Status
                        Text {
                            text: laneStatusId || "-"
                            color: Theme.colors.text
                            font.family: Theme.typography.familySans
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            elide: Text.ElideRight
                            width: 100
                            height: Theme.spacing.s10
                            leftPadding: Theme.spacing.s2
                            rightPadding: Theme.spacing.s2
                        }

                        // Lane Name
                        Text {
                            text: laneName || "-"
                            color: Theme.colors.text
                            font.family: Theme.typography.familySans
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            elide: Text.ElideRight
                            width: 120
                            height: Theme.spacing.s10
                            leftPadding: Theme.spacing.s2
                            rightPadding: Theme.spacing.s2
                        }

                        // Direction
                        Text {
                            text: transitDirection || "-"
                            color: transitDirection === "IN" ? Theme.colors.success : Theme.colors.warning
                            font.family: Theme.typography.familySans
                            font.weight: Theme.typography.weightMedium
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            elide: Text.ElideRight
                            width: 100
                            height: Theme.spacing.s10
                            leftPadding: Theme.spacing.s2
                            rightPadding: Theme.spacing.s2
                        }

                        // Color
                        Text {
                            text: hasTransitInfo ? (colors || "-") : "-"
                            color: Theme.colors.text
                            font.family: Theme.typography.familySans
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            elide: Text.ElideRight
                            width: 80
                            height: Theme.spacing.s10
                            leftPadding: Theme.spacing.s2
                            rightPadding: Theme.spacing.s2
                        }

                        // Macro Class
                        Text {
                            text: hasTransitInfo ? (macroClass || "-") : "-"
                            color: Theme.colors.text
                            font.family: Theme.typography.familySans
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            elide: Text.ElideRight
                            width: 100
                            height: Theme.spacing.s10
                            leftPadding: Theme.spacing.s2
                            rightPadding: Theme.spacing.s2
                        }

                        // Micro Class
                        Text {
                            text: hasTransitInfo ? (microClass || "-") : "-"
                            color: Theme.colors.text
                            font.family: Theme.typography.familySans
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            elide: Text.ElideRight
                            width: 100
                            height: Theme.spacing.s10
                            leftPadding: Theme.spacing.s2
                            rightPadding: Theme.spacing.s2
                        }

                        // Make
                        Text {
                            text: hasTransitInfo ? (make || "-") : "-"
                            color: Theme.colors.text
                            font.family: Theme.typography.familySans
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            elide: Text.ElideRight
                            width: 100
                            height: Theme.spacing.s10
                            leftPadding: Theme.spacing.s2
                            rightPadding: Theme.spacing.s2
                        }

                        // Model
                        Text {
                            text: hasTransitInfo ? (models || "-") : "-"
                            color: Theme.colors.text
                            font.family: Theme.typography.familySans
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            elide: Text.ElideRight
                            width: 100
                            height: Theme.spacing.s10
                            leftPadding: Theme.spacing.s2
                            rightPadding: Theme.spacing.s2
                        }

                        // Country
                        Text {
                            text: hasTransitInfo ? (country || "-") : "-"
                            color: Theme.colors.text
                            font.family: Theme.typography.familySans
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            elide: Text.ElideRight
                            width: 80
                            height: Theme.spacing.s10
                            leftPadding: Theme.spacing.s2
                            rightPadding: Theme.spacing.s2
                        }

                        // Kemler
                        Text {
                            text: hasTransitInfo ? (kemler || "-") : "-"
                            color: Theme.colors.text
                            font.family: Theme.typography.familySans
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            elide: Text.ElideRight
                            width: 80
                            height: Theme.spacing.s10
                            leftPadding: Theme.spacing.s2
                            rightPadding: Theme.spacing.s2
                        }

                        // Auth
                        Text {
                            text: hasPermission ? (auth || "-") : "-"
                            color: auth === "ACCEPT" ? Theme.colors.success : Theme.colors.error
                            font.family: Theme.typography.familySans
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            elide: Text.ElideRight
                            width: 80
                            height: Theme.spacing.s10
                            leftPadding: Theme.spacing.s2
                            rightPadding: Theme.spacing.s2
                        }

                        // Auth Message
                        Text {
                            text: hasPermission ? (authMessage || "-") : "-"
                            color: Theme.colors.text
                            font.family: Theme.typography.familySans
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            elide: Text.ElideRight
                            width: 150
                            height: Theme.spacing.s10
                            leftPadding: Theme.spacing.s2
                            rightPadding: Theme.spacing.s2
                        }

                        // Permission Type
                        Text {
                            text: hasPermission ? (permissionType || "-") : "-"
                            color: Theme.colors.text
                            font.family: Theme.typography.familySans
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            elide: Text.ElideRight
                            width: 120
                            height: Theme.spacing.s10
                            leftPadding: Theme.spacing.s2
                            rightPadding: Theme.spacing.s2
                        }

                        // Vehicle Plate
                        Text {
                            text: hasPermission ? (vehiclePlate || "-") : "-"
                            color: Theme.colors.text
                            font.family: Theme.typography.familySans
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            elide: Text.ElideRight
                            width: 120
                            height: Theme.spacing.s10
                            leftPadding: Theme.spacing.s2
                            rightPadding: Theme.spacing.s2
                        }

                        // Person Name
                        Text {
                            text: hasPermission ? (peopleFullname || "-") : "-"
                            color: Theme.colors.text
                            font.family: Theme.typography.familySans
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            elide: Text.ElideRight
                            width: 150
                            height: Theme.spacing.s10
                            leftPadding: Theme.spacing.s2
                            rightPadding: Theme.spacing.s2
                        }

                        // Company
                        Text {
                            text: hasPermission ? (companyFullname || "-") : "-"
                            color: Theme.colors.text
                            font.family: Theme.typography.familySans
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            elide: Text.ElideRight
                            width: 200
                            height: Theme.spacing.s10
                            leftPadding: Theme.spacing.s2
                            rightPadding: Theme.spacing.s2
                        }
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
}
