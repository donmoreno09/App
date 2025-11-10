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
    Layout.maximumWidth: parent.width

    required property var model

    onWidthChanged: {
            console.log("TransitsTable GroupBox width:", width)
        }

    contentItem: ColumnLayout {
            width: parent.width
            spacing: Theme.spacing.s2


            Component.onCompleted: {
                        console.log("=== ColumnLayout Initial ===")
                        console.log("  width:", width)
                        console.log("  implicitWidth:", implicitWidth)
                        console.log("  parent (GroupBox) width:", parent ? parent.width : "no parent")
                        console.log("  root.width:", root.width)
                        console.log("  root.availableWidth:", root.availableWidth)
                    }

                    onWidthChanged: {
                        console.log("ColumnLayout width changed:", width)
                    }

            // Header wrapper with clipping
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: Theme.spacing.s10
                clip: true

                TableHeader {
                    width: parent.width  // ✅ Match the clipping container width (472px)
                    height: parent.height
                    columns: ColumnConfig.columns
                    contentX: listView.contentX
                }
            }

            ListView {
                id: listView
                Layout.fillWidth: true
                Layout.preferredHeight: 300
                Layout.maximumWidth: parent.width
                clip: true
                model: root.model
                contentWidth: ColumnConfig.totalWidth

                Component.onCompleted: {
                        console.log("=== ListView Initial ===")
                        console.log("  width:", width)
                        console.log("  implicitWidth:", implicitWidth)
                        console.log("  contentWidth:", contentWidth)
                        console.log("  parent.width:", parent ? parent.width : "no parent")
                    }

                onWidthChanged: {
                        console.log("ListView width:", width, "- contentWidth:", contentWidth)
                        if (width > 500) {
                            console.warn("⚠️ LISTVIEW EXPANDED:", width)
                        }
                    }

                    onImplicitWidthChanged: {
                        console.log("ListView implicitWidth changed:", implicitWidth)
                    }

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
