import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.SidePanel 1.0
import App.Features.Language 1.0

PanelTemplate {
    title.text: (TranslationManager.revision, qsTr("Accordion Test"))

    ScrollView {
        id: sv
        anchors.fill: parent

        Frame {
            padding: Theme.spacing.s4
            width: sv.availableWidth

            ColumnLayout {
                anchors.fill: parent
                spacing: Theme.spacing.s6

                // 1. Basic Accordion States
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacing.s4

                    Text {
                        text: "1. Basic Accordion (Default Variant)"
                        font.pixelSize: Theme.typography.fontSize200
                        font.weight: Theme.typography.weightSemibold
                        color: Theme.colors.accent500
                    }

                    UI.Accordion {
                        Layout.fillWidth: true
                        variant: UI.AccordionStyles.Default

                        headerContent: RowLayout {
                            anchors.fill: parent
                            spacing: Theme.spacing.s3

                            Text {
                                text: "Click to expand"
                                color: Theme.colors.text
                                font.family: Theme.typography.bodySans25Family
                                font.pointSize: Theme.typography.bodySans25Size
                                font.weight: Theme.typography.bodySans25Weight
                                Layout.fillWidth: true
                            }
                        }

                        content: ColumnLayout {
                            width: parent.width
                            spacing: Theme.spacing.s2

                            Text {
                                text: "This is the accordion content."
                                color: Theme.colors.text
                                font.family: Theme.typography.bodySans25Family
                                font.pointSize: Theme.typography.bodySans25Size
                                font.weight: Theme.typography.bodySans25Weight
                            }

                            Text {
                                text: "It can contain any QML components."
                                color: Theme.colors.textMuted
                                font.family: Theme.typography.bodySans15Family
                                font.pointSize: Theme.typography.bodySans15Size
                                font.weight: Theme.typography.bodySans15Weight
                            }
                        }
                    }
                }

                // 2. Variant Examples
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacing.s4

                    Text {
                        text: "2. Accordion Variants"
                        font.pixelSize: Theme.typography.fontSize200
                        font.weight: Theme.typography.weightSemibold
                        color: Theme.colors.accent500
                    }

                    // Urgent Variant
                    UI.Accordion {
                        Layout.fillWidth: true
                        variant: UI.AccordionStyles.Urgent
                        expanded: false

                        headerContent: RowLayout {
                            anchors.fill: parent
                            spacing: Theme.spacing.s3

                            Text {
                                text: "Urgent Notification"
                                color: Theme.colors.text
                                font.family: Theme.typography.bodySans25Family
                                font.pointSize: Theme.typography.bodySans25Size
                                font.weight: Theme.typography.bodySans25Weight
                                Layout.fillWidth: true
                            }

                            Rectangle {
                                Layout.preferredWidth: Theme.spacing.s16
                                Layout.preferredHeight: Theme.spacing.s6
                                radius: Theme.radius.sm
                                color: Theme.colors.error500

                                Text {
                                    anchors.centerIn: parent
                                    text: "URGENT"
                                    color: Theme.colors.white
                                    font.family: Theme.typography.bodySans15Family
                                    font.pointSize: Theme.typography.bodySans15Size
                                    font.weight: Theme.typography.bodySans15StrongWeight
                                }
                            }
                        }

                        content: ColumnLayout {
                            width: parent.width
                            spacing: Theme.spacing.s3

                            Text {
                                text: "Critical issue requires immediate attention!"
                                color: Theme.colors.text
                                font.family: Theme.typography.bodySans25Family
                                font.pointSize: Theme.typography.bodySans25Size
                                font.weight: Theme.typography.bodySans25Weight
                            }
                        }
                    }

                    // Warning Variant
                    UI.Accordion {
                        Layout.fillWidth: true
                        variant: UI.AccordionStyles.Warning

                        headerContent: RowLayout {
                            anchors.fill: parent
                            spacing: Theme.spacing.s3

                            Text {
                                text: "Warning Message"
                                color: Theme.colors.text
                                font.family: Theme.typography.bodySans25Family
                                font.pointSize: Theme.typography.bodySans25Size
                                font.weight: Theme.typography.bodySans25Weight
                                Layout.fillWidth: true
                            }

                            Rectangle {
                                Layout.preferredWidth: Theme.spacing.s16
                                Layout.preferredHeight: Theme.spacing.s6
                                radius: Theme.radius.sm
                                color: Theme.colors.caution500

                                Text {
                                    anchors.centerIn: parent
                                    text: "WARNING"
                                    color: Theme.colors.black
                                    font.family: Theme.typography.bodySans15Family
                                    font.pointSize: Theme.typography.bodySans15Size
                                    font.weight: Theme.typography.bodySans15StrongWeight
                                }
                            }
                        }

                        content: ColumnLayout {
                            width: parent.width
                            spacing: Theme.spacing.s3

                            Text {
                                text: "Please review this warning message."
                                color: Theme.colors.text
                                font.family: Theme.typography.bodySans25Family
                                font.pointSize: Theme.typography.bodySans25Size
                                font.weight: Theme.typography.bodySans25Weight
                            }
                        }
                    }

                    // Success Variant
                    UI.Accordion {
                        Layout.fillWidth: true
                        variant: UI.AccordionStyles.Success

                        headerContent: RowLayout {
                            anchors.fill: parent
                            spacing: Theme.spacing.s3

                            Text {
                                text: "Success Update"
                                color: Theme.colors.text
                                font.family: Theme.typography.bodySans25Family
                                font.pointSize: Theme.typography.bodySans25Size
                                font.weight: Theme.typography.bodySans25Weight
                                Layout.fillWidth: true
                            }

                            Rectangle {
                                Layout.preferredWidth: Theme.spacing.s16
                                Layout.preferredHeight: Theme.spacing.s6
                                radius: Theme.radius.sm
                                color: Theme.colors.success500

                                Text {
                                    anchors.centerIn: parent
                                    text: "UPDATED"
                                    color: Theme.colors.white
                                    font.family: Theme.typography.bodySans15Family
                                    font.pointSize: Theme.typography.bodySans15Size
                                    font.weight: Theme.typography.bodySans15StrongWeight
                                }
                            }
                        }

                        content: ColumnLayout {
                            width: parent.width
                            spacing: Theme.spacing.s3

                            Text {
                                text: "Operation completed successfully!"
                                color: Theme.colors.text
                                font.family: Theme.typography.bodySans25Family
                                font.pointSize: Theme.typography.bodySans25Size
                                font.weight: Theme.typography.bodySans25Weight
                            }
                        }
                    }
                }

                // In AccordionPanel.qml, update the notification examples section:

                // 3. Notification-like Examples (from screenshots)
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacing.s4

                    Text {
                        text: "3. Notification Examples"
                        font.pixelSize: Theme.typography.fontSize200
                        font.weight: Theme.typography.weightSemibold
                        color: Theme.colors.accent500
                    }

                    UI.Accordion {
                        Layout.fillWidth: true
                        variant: UI.AccordionStyles.Urgent
                        expanded: false

                        headerContent: RowLayout {
                            anchors.fill: parent
                            spacing: Theme.spacing.s3

                            // Left side: Title + Preview stacked
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: Theme.spacing.s1

                                // Bold title
                                Text {
                                    text: "Truck: EA624F714"
                                    color: Theme.colors.text
                                    font.family: Theme.typography.bodySans25StrongFamily
                                    font.pointSize: Theme.typography.bodySans25StrongSize
                                    font.weight: Theme.typography.bodySans25StrongWeight
                                    Layout.fillWidth: true
                                }

                                // Preview text (lighter, smaller, elided)
                                Text {
                                    text: "Segnalazione Avvenuta alle 10:00 del 27/10/2025"
                                    color: Theme.colors.textMuted
                                    font.family: Theme.typography.bodySans15Family
                                    font.pointSize: Theme.typography.bodySans15Size
                                    font.weight: Theme.typography.bodySans15Weight
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }

                            // Right side: Badge
                            Rectangle {
                                Layout.preferredWidth: Theme.spacing.s16
                                Layout.preferredHeight: Theme.spacing.s6
                                radius: Theme.radius.sm
                                color: Theme.colors.error500

                                Text {
                                    anchors.centerIn: parent
                                    text: "URGENT"
                                    color: Theme.colors.white
                                    font.family: Theme.typography.bodySans15Family
                                    font.pointSize: Theme.typography.bodySans15Size
                                    font.weight: Theme.typography.bodySans15StrongWeight
                                }
                            }
                        }

                        content: ColumnLayout {
                            width: parent.width
                            spacing: Theme.spacing.s3

                            Text {
                                text: "EA624F714"
                                color: Theme.colors.text
                                font.family: Theme.typography.bodySans25StrongFamily
                                font.pointSize: Theme.typography.bodySans25StrongSize
                                font.weight: Theme.typography.bodySans25StrongWeight
                            }

                            Text {
                                text: "Problema: Problema con la merce"
                                color: Theme.colors.text
                                font.family: Theme.typography.bodySans25Family
                                font.pointSize: Theme.typography.bodySans25Size
                                font.weight: Theme.typography.bodySans25Weight
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }

                            Text {
                                text: "Orario di arrivo ricalcolato: 2:00 PM"
                                color: Theme.colors.textMuted
                                font.family: Theme.typography.bodySans15Family
                                font.pointSize: Theme.typography.bodySans15Size
                                font.weight: Theme.typography.bodySans15Weight
                            }

                            Text {
                                text: "Posizione: Lat 42.5167° N, Lon 12.3833° E"
                                color: Theme.colors.textMuted
                                font.family: Theme.typography.bodySans15Family
                                font.pointSize: Theme.typography.bodySans15Size
                                font.weight: Theme.typography.bodySans15Weight
                            }

                            UI.Button {
                                Layout.alignment: Qt.AlignRight
                                text: "Delete"
                                variant: UI.ButtonStyles.Danger
                                Layout.preferredHeight: Theme.spacing.s8
                            }
                        }
                    }

                    // SUCCESS variant
                    UI.Accordion {
                        Layout.fillWidth: true
                        variant: UI.AccordionStyles.Success

                        headerContent: RowLayout {
                            anchors.fill: parent
                            spacing: Theme.spacing.s3

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: Theme.spacing.s1

                                Text {
                                    text: "Truck: BA43F716"
                                    color: Theme.colors.text
                                    font.family: Theme.typography.bodySans25StrongFamily
                                    font.pointSize: Theme.typography.bodySans25StrongSize
                                    font.weight: Theme.typography.bodySans25StrongWeight
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: "Segnalazione Avvenuta alle 10:00 del 27/10/2025"
                                    color: Theme.colors.textMuted
                                    font.family: Theme.typography.bodySans15Family
                                    font.pointSize: Theme.typography.bodySans15Size
                                    font.weight: Theme.typography.bodySans15Weight
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }

                            Rectangle {
                                Layout.preferredWidth: Theme.spacing.s16
                                Layout.preferredHeight: Theme.spacing.s6
                                radius: Theme.radius.sm
                                color: Theme.colors.success500

                                Text {
                                    anchors.centerIn: parent
                                    text: "UPDATED"
                                    color: Theme.colors.white
                                    font.family: Theme.typography.bodySans15Family
                                    font.pointSize: Theme.typography.bodySans15Size
                                    font.weight: Theme.typography.bodySans15StrongWeight
                                }
                            }
                        }

                        content: ColumnLayout {
                            width: parent.width
                            spacing: Theme.spacing.s3

                            Text {
                                text: "Segnalazione Avvenuta alle 10:00 del 27/10/2025"
                                color: Theme.colors.text
                                font.family: Theme.typography.bodySans25Family
                                font.pointSize: Theme.typography.bodySans25Size
                                font.weight: Theme.typography.bodySans25Weight
                            }

                            UI.Button {
                                Layout.alignment: Qt.AlignRight
                                text: "Delete"
                                variant: UI.ButtonStyles.Primary
                                Layout.preferredHeight: Theme.spacing.s8
                            }
                        }
                    }

                    // WARNING variant
                    UI.Accordion {
                        Layout.fillWidth: true
                        variant: UI.AccordionStyles.Warning

                        headerContent: RowLayout {
                            anchors.fill: parent
                            spacing: Theme.spacing.s3

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: Theme.spacing.s1

                                Text {
                                    text: "Ship: VF755987"
                                    color: Theme.colors.text
                                    font.family: Theme.typography.bodySans25StrongFamily
                                    font.pointSize: Theme.typography.bodySans25StrongSize
                                    font.weight: Theme.typography.bodySans25StrongWeight
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: "Segnalazione Avvenuta alle 10:00 del 27/10/2025"
                                    color: Theme.colors.textMuted
                                    font.family: Theme.typography.bodySans15Family
                                    font.pointSize: Theme.typography.bodySans15Size
                                    font.weight: Theme.typography.bodySans15Weight
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }

                            Rectangle {
                                Layout.preferredWidth: Theme.spacing.s16
                                Layout.preferredHeight: Theme.spacing.s6
                                radius: Theme.radius.sm
                                color: Theme.colors.caution500

                                Text {
                                    anchors.centerIn: parent
                                    text: "WARNING"
                                    color: Theme.colors.black
                                    font.family: Theme.typography.bodySans15Family
                                    font.pointSize: Theme.typography.bodySans15Size
                                    font.weight: Theme.typography.bodySans15StrongWeight
                                }
                            }
                        }

                        content: ColumnLayout {
                            width: parent.width
                            spacing: Theme.spacing.s3

                            Text {
                                text: "Segnalazione Avvenuta alle 10:00 del 27/10/2025"
                                color: Theme.colors.text
                                font.family: Theme.typography.bodySans25Family
                                font.pointSize: Theme.typography.bodySans25Size
                                font.weight: Theme.typography.bodySans25Weight
                            }

                            UI.Button {
                                Layout.alignment: Qt.AlignRight
                                text: "Delete"
                                variant: UI.ButtonStyles.Warning
                                Layout.preferredHeight: Theme.spacing.s8
                            }
                        }
                    }
                }

                Item { Layout.fillHeight: true }
            }
        }
    }
}
