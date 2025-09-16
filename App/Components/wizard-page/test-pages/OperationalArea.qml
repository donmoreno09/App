import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import App.Themes 1.0
import App.Features.Language 1.0

Item {
    id: operationalAreaStep

    // Wizard integration
    property var wizardData: ({})

    implicitHeight: contentLayout.implicitHeight + 48

    ColumnLayout {
        id: contentLayout
        anchors.fill: parent
        anchors.margins: 24
        spacing: 24

        // Area Type Section
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 12

            Text {
                text: (TranslationManager.revision, qsTr("Area Type"))
                color: "#ffffff"
                font.family: Theme.typography.familySans
                font.pixelSize: Theme.typography.fontSize175
                font.weight: Theme.typography.weightMedium
            }

            Row {
                spacing: 12

                Repeater {
                    model: [
                        {name: (TranslationManager.revision, qsTr("Ellipse")), icon: "○"},
                        {name: (TranslationManager.revision, qsTr("Rectangle")), icon: "□"},
                        {name: (TranslationManager.revision, qsTr("Sector")), icon: "◗"},
                        {name: (TranslationManager.revision, qsTr("Polygon")), icon: "⬟"},
                        {name: (TranslationManager.revision, qsTr("Arc")), icon: "⌒"}
                    ]

                    Button {
                        width: 80
                        height: 60

                        property bool isSelected: wizardData.areaType === modelData.name

                        background: Rectangle {
                            color: parent.isSelected ? "#4285f4" : (parent.hovered ? "#333333" : "#2a2a2a")
                            border.color: parent.isSelected ? "#4285f4" : "#666666"
                            border.width: 1
                            radius: 4
                        }

                        Column {
                            anchors.centerIn: parent
                            spacing: 4

                            Text {
                                text: modelData.icon
                                color: "#ffffff"
                                font.family: Theme.typography.familySans
                                font.pixelSize: Theme.typography.fontSize200
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                text: modelData.name
                                color: "white"
                                font.family: Theme.typography.familySans
                                font.pixelSize: Theme.typography.fontSize125
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }

                        onClicked: {
                            wizardData.areaType = modelData.name
                        }
                    }
                }
            }
        }

        // Area Details Section
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 12

            Text {
                text: (TranslationManager.revision, qsTr("Area Details"))
                color: "#ffffff"
                font.family: Theme.typography.familySans
                font.pixelSize: Theme.typography.fontSize175
                font.weight: Theme.typography.weightMedium
            }

            GridLayout {
                columns: 2
                columnSpacing: 16
                rowSpacing: 12
                Layout.fillWidth: true

                // Latitude
                TextField {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    placeholderText: (TranslationManager.revision, qsTr("Latitude"))
                    placeholderTextColor: "white"
                    text: wizardData.latitude || ""

                    background: Rectangle {
                        color: "#2a2a2a"
                        border.color: parent.activeFocus ? "#4285f4" : "#666666"
                        border.width: 1
                        radius: 4
                    }

                    color: "#ffffff"

                    onTextChanged: {
                        wizardData.latitude = text
                    }
                }

                // Longitude
                TextField {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    placeholderText: (TranslationManager.revision, qsTr("Longitude"))
                    placeholderTextColor: "white"
                    text: wizardData.longitude || ""

                    background: Rectangle {
                        color: "#2a2a2a"
                        border.color: parent.activeFocus ? "#4285f4" : "#666666"
                        border.width: 1
                        radius: 4
                    }

                    color: "#ffffff"

                    onTextChanged: {
                        wizardData.longitude = text
                    }
                }

                // Radius
                TextField {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    placeholderText: (TranslationManager.revision, qsTr("Radius (m)"))
                    placeholderTextColor: "white"
                    text: wizardData.radius || ""

                    background: Rectangle {
                        color: "#2a2a2a"
                        border.color: parent.activeFocus ? "#4285f4" : "#666666"
                        border.width: 1
                        radius: 4
                    }

                    color: "#ffffff"

                    onTextChanged: {
                        wizardData.radius = text
                    }
                }

                // Rotation
                TextField {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    placeholderText: (TranslationManager.revision, qsTr("Rotation (°)"))
                    placeholderTextColor: "white"
                    text: wizardData.rotation || ""

                    background: Rectangle {
                        color: "#2a2a2a"
                        border.color: parent.activeFocus ? "#4285f4" : "#666666"
                        border.width: 1
                        radius: 4
                    }

                    color: "#ffffff"

                    onTextChanged: {
                        wizardData.rotation = text
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
