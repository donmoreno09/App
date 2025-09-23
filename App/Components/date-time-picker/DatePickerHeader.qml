import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI

Item {
    id: root

    // Props
    property string currentView: "calendar"
    property int currentMonth: 0
    property int currentYear: 2025

    // Signals
    signal previousClicked()
    signal nextClicked()
    signal headerClicked()

    Layout.preferredWidth: 280
    Layout.preferredHeight: 40
    Layout.minimumHeight: 40

    RowLayout {
        anchors.fill: parent
        spacing: Theme.spacing.s3

        // Previous button
        UI.Button {
            Layout.preferredWidth: Theme.spacing.s8
            Layout.preferredHeight: Theme.spacing.s8
            variant: "ghost"
            display: AbstractButton.IconOnly
            backgroundRect.color: Theme.colors.transparent
            backgroundRect.border.width: Theme.borders.b0

            contentItem: Text {
                anchors.centerIn: parent
                text: "❮"
                font.family: Theme.typography.familySans
                font.pixelSize: Theme.typography.fontSize150
                color: Theme.colors.text
            }

            onClicked: root.previousClicked()
        }

        // Title - clickable for navigation
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: _titleMouseArea.containsMouse ? Theme.colors.secondary500 : Theme.colors.transparent
            radius: Theme.radius.sm

            Text {
                anchors.centerIn: parent
                text: root._getTitleText()
                font.family: Theme.typography.familySans
                font.pixelSize: Theme.typography.fontSize200
                font.weight: Theme.typography.weightMedium
                color: Theme.colors.text
            }

            MouseArea {
                id: _titleMouseArea
                anchors.fill: parent
                hoverEnabled: root._canNavigateUp()
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                enabled: root._canNavigateUp()

                onClicked: {
                    if (enabled) {
                        root.headerClicked()
                    }
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 150
                    easing.type: Easing.OutCubic
                }
            }
        }

        // Next button
        UI.Button {
            Layout.preferredWidth: Theme.spacing.s8
            Layout.preferredHeight: Theme.spacing.s8
            variant: "ghost"
            display: AbstractButton.IconOnly
            backgroundRect.color: Theme.colors.transparent
            backgroundRect.border.width: Theme.borders.b0

            contentItem: Text {
                anchors.centerIn: parent
                text: "❯"
                font.family: Theme.typography.familySans
                font.pixelSize: Theme.typography.fontSize150
                color: Theme.colors.text
            }

            onClicked: root.nextClicked()
        }
    }

    // Helper functions
    function _getTitleText() {
        switch (currentView) {
            case "year":
                const startYear = Math.floor(currentYear / 12) * 12
                return startYear + " - " + (startYear + 11)
            case "month":
                return currentYear.toString()
            case "calendar":
                return Qt.locale().monthName(currentMonth) + " " + currentYear
            default:
                return ""
        }
    }

    function _canNavigateUp() {
        // Can navigate up from calendar and month views, but not from year view
        return currentView === "calendar" || currentView === "month"
    }
}
