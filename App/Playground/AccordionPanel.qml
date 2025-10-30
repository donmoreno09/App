import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.SidePanel 1.0
import App.Features.Language 1.0

PanelTemplate {
    title.text: (TranslationManager.revision, qsTr("Notifications"))

    ScrollView {
        id: sv
        anchors.fill: parent

        Frame {
            padding: Theme.spacing.s4
            width: sv.availableWidth

            ColumnLayout {
                anchors.fill: parent
                spacing: Theme.spacing.s6

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacing.s4

                    // HIGH priority notification
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
                                    font.weight: Theme.typography.weightBold
                                    Layout.fillWidth: true
                                }

                                // Preview text - shows actual issue content
                                Text {
                                    text: "Issue: Goods Issue"
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
                                    text: "HIGH"
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
                                font.weight: Theme.typography.weightBold
                            }

                            Text {
                                text: "Issue: Goods Issue"
                                color: Theme.colors.text
                                font.family: Theme.typography.bodySans25Family
                                font.pointSize: Theme.typography.bodySans25Size
                                font.weight: Theme.typography.bodySans25Weight
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }

                            Text {
                                text: "Recalculated arrival time: 2:00 PM"
                                color: Theme.colors.textMuted
                                font.family: Theme.typography.bodySans15Family
                                font.pointSize: Theme.typography.bodySans15Size
                                font.weight: Theme.typography.bodySans15Weight
                            }

                            Text {
                                text: "Position: Lat 42.5167° N, Lon 12.3833° E"
                                color: Theme.colors.textMuted
                                font.family: Theme.typography.bodySans15Family
                                font.pointSize: Theme.typography.bodySans15Size
                                font.weight: Theme.typography.bodySans15Weight
                            }

                            UI.Button {
                                Layout.alignment: Qt.AlignRight
                                text: "Delete"
                                variant: UI.ButtonStyles.Ghost
                                Layout.preferredHeight: Theme.spacing.s8
                            }
                        }
                    }

                    // MEDIUM priority notification
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
                                    font.weight: Theme.typography.weightBold
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: "Report occurred at 10:00 on 27/10/2025"
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
                                    text: "MEDIUM"
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
                                text: "Report occurred at 10:00 on 27/10/2025"
                                color: Theme.colors.text
                                font.family: Theme.typography.bodySans25Family
                                font.pointSize: Theme.typography.bodySans25Size
                                font.weight: Theme.typography.bodySans25Weight
                            }

                            UI.Button {
                                Layout.alignment: Qt.AlignRight
                                text: "Delete"
                                variant: UI.ButtonStyles.Ghost
                                Layout.preferredHeight: Theme.spacing.s8
                            }
                        }
                    }

                    // LOW priority notification
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
                                    font.weight: Theme.typography.weightBold
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: "Report occurred at 10:00 on 27/10/2025"
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
                                    text: "LOW"
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
                                text: "Report occurred at 10:00 on 27/10/2025"
                                color: Theme.colors.text
                                font.family: Theme.typography.bodySans25Family
                                font.pointSize: Theme.typography.bodySans25Size
                                font.weight: Theme.typography.bodySans25Weight
                            }

                            UI.Button {
                                Layout.alignment: Qt.AlignRight
                                text: "Delete"
                                variant: UI.ButtonStyles.Ghost
                                Layout.preferredHeight: Theme.spacing.s8
                            }
                        }
                    }
                }

                UI.VerticalSpacer {}

                UI.HorizontalDivider {}

                RowLayout {
                    Layout.margins: Theme.spacing.s3
                    spacing: Theme.spacing.s2

                    UI.Button {
                        Layout.fillWidth: true
                        variant: UI.ButtonStyles.Ghost
                        text: (TranslationManager.revision, qsTr("Back"))

                        background: Rectangle {
                            color: Theme.colors.transparent
                            border.width: 0
                        }
                    }

                    UI.Button {
                        Layout.fillWidth: true
                        variant: UI.ButtonStyles.Primary
                        text: (TranslationManager.revision, qsTr("Delete All"))
                    }
                }
            }
        }
    }
}
