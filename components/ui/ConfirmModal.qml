import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import raise.singleton.language 1.0

Popup {
    id: popup

    // Externally configurable properties
    property string title: qsTr("Confirm")
    property string description: qsTr("Are you sure you want to proceed?")
    property string cancelBtnText: qsTr("Cancel")
    property string confirmBtnText: qsTr("OK")

    signal confirm()
    signal cancel()

    // Auto-retranslate when language changes
    function retranslateUi() {
        title = qsTr("Confirm")
        description = qsTr("Are you sure you want to proceed?")
        cancelBtnText = qsTr("Cancel")
        confirmBtnText = qsTr("OK")
    }

    width: 320
    modal: true
    focus: true
    parent: Overlay.overlay
    x: Math.round((parent.width - width) / 2)
    y: Math.round((parent.height - height) / 2)
    closePolicy: Popup.CloseOnEscape

    background: Rectangle {
        radius: 6
        height: popup.implicitHeight
        color: "#f21f3154"
    }

    contentItem: ColumnLayout {
        id: popupContent
        spacing: 12

        Text {
            text: popup.title
            font.bold: true
            color: "#ffffff"
        }

        Text {
            text: popup.description
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            wrapMode: Text.WordWrap
            color: "#ffffff"
        }

        Row {
            Layout.alignment: Qt.AlignRight
            spacing: 6

            StyledButton {
                text: popup.cancelBtnText
                onClicked: {
                    popup.close()
                    cancel()
                }
            }

            StyledButton {
                text: popup.confirmBtnText
                onClicked: {
                    popup.close()
                    confirm()
                }
            }
        }
    }

    Connections {
        target: LanguageController
        function onLanguageChanged() {
            console.log("Language changed signal received - auto-retranslating")
            popup.retranslateUi()
        }
        function onLanguageLoadFailed(language, reason) {
            console.error("Language load failed:", language, "-", reason)
        }
    }
}
