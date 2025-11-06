import QtQuick 6.8
import QtQuick.Layouts 6.8
import QtQuick.Controls 6.8
import App.Themes 1.0
import App.Features.ViGateServices

GroupBox {
    id: root
    title: qsTr("Transits")
    Layout.fillWidth: true
    Layout.fillHeight: true

    required property var model

    contentItem: ColumnLayout {
            spacing: Theme.spacing.s2

            // Header
            TableHeader {
                Layout.fillWidth: true
                Layout.preferredHeight: Theme.spacing.s10
                columns: ColumnConfig.columns
                contentX: listView.contentX
            }

            ListView {
                id: listView
                Layout.fillWidth: true
                Layout.preferredHeight: 300
                clip: true
                model: root.model
                contentWidth: ColumnConfig.totalWidth
                flickableDirection: Flickable.HorizontalAndVerticalFlick
                boundsBehavior: Flickable.StopAtBounds

                // Performance optimizations
                cacheBuffer: Theme.spacing.s10 * 10
                reuseItems: true

                // Smooth scrolling
                maximumFlickVelocity: 2500
                flickDeceleration: 1500

                delegate: TransitRow {
                    columns: ColumnConfig.columns
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
