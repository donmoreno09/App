import QtQuick 6.8
import QtQuick.Layouts 6.8
import QtQuick.Controls 6.8
import App.Themes 1.0

GroupBox {
    id: root
    title: qsTr("Pedestrians")
    Layout.fillWidth: true

    required property var model

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacing.s2
        spacing: Theme.spacing.s2

        // Header
        Rectangle {
            Layout.fillWidth: true
            height: Theme.spacing.s8
            color: Theme.colors.surface
            radius: Theme.radius.sm

            RowLayout {
                anchors.fill: parent
                anchors.margins: Theme.spacing.s2
                spacing: Theme.spacing.s2

                Text {
                    text: qsTr("Start Date")
                    font.family: Theme.typography.familySans
                    font.weight: Theme.typography.weightSemibold
                    color: Theme.colors.text
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                    Layout.preferredWidth: 2
                }

                Text {
                    text: qsTr("Direction")
                    font.family: Theme.typography.familySans
                    font.weight: Theme.typography.weightSemibold
                    color: Theme.colors.text
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                }
            }
        }

        // TableView
        ScrollView {
            Layout.fillWidth: true
            Layout.preferredHeight: 180
            clip: true

            ListView {
                model: root.model
                spacing: Theme.spacing.s0_5

                delegate: Rectangle {
                    required property int index
                    required property string startDate
                    required property string direction

                    width: ListView.view.width
                    height: Theme.spacing.s8
                    color: Theme.colors.transparent
                    radius: Theme.radius.xs

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: Theme.spacing.s2
                        spacing: Theme.spacing.s2

                        Text {
                            text: startDate || "-"
                            font.family: Theme.typography.familySans
                            color: Theme.colors.text
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                            Layout.preferredWidth: 2
                        }

                        Text {
                            text: direction || "-"
                            font.family: Theme.typography.familySans
                            font.weight: Theme.typography.weightMedium
                            color: direction === "IN" ? Theme.colors.success : Theme.colors.warning
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                            Layout.preferredWidth: 1
                        }
                    }
                }
            }
        }
    }
}
