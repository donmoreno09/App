import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.Language 1.0

UI.ComboBox {
    id: root

    labelText: `${TranslationManager.revision}` && qsTr("Severity(*)")
    valueRole: "value"
    textRole: "name"

    model: ListModel {
        ListElement { value: 0; name: qsTr("Low"); color: "#FFE8A3" }
        ListElement { value: 1; name: qsTr("Medium"); color: "#E5A000" }
        ListElement { value: 2; name: qsTr("High"); color: "#EC221F" }
    }

    comboBox.delegate: ItemDelegate {
        width: root.comboBox.popup.width
        height: Theme.spacing.s10

        contentItem: RowLayout {
            spacing: Theme.spacing.s2

            Item { Layout.preferredWidth: Theme.spacing.s3 }

            Rectangle {
                width: 8
                height: 8
                radius: 4
                color: model.color
            }

            Text {
                text: model.name
                color: Theme.colors.text
                font: root.comboBox.font
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
                Layout.fillWidth: true
            }
        }

        background: Rectangle {
            color: {
                if (parent.highlighted) return Qt.darker(Theme.colors.surface, 1.5)
                if (parent.hovered) return Qt.darker(Theme.colors.surface, 1.5)
                return Theme.colors.transparent
            }
            radius: Theme.radius.sm
        }
    }

    comboBox.contentItem: RowLayout {
        spacing: Theme.spacing.s2

        Item { Layout.preferredWidth: Theme.spacing.s4 }

        Rectangle {
            width: 8
            height: 8
            radius: 4
            color: {
                if (root.currentIndex >= 0 && root.model.get(root.currentIndex)) {
                    return root.model.get(root.currentIndex).color
                }
                return "#FFCC00"
            }
        }

        Text {
            text: root.comboBox.displayText
            color: root.comboBox.enabled ? Theme.colors.text : Theme.colors.textMuted
            font: root.comboBox.font
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
            Layout.fillWidth: true
        }

        Image {
            Layout.preferredWidth: Theme.icons.sizeSm
            Layout.preferredHeight: Theme.icons.sizeSm
            source: "qrc:/App/assets/icons/chevron-down-combobox.svg"
            rotation: root.comboBox.popup.visible ? 180 : 0
        }

        Item { Layout.preferredWidth: Theme.spacing.s4 }
    }
}
