import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15


Popup {
    id: popup

    property string title: root.titleText
    property string description: root.descriptionText
    property string cancelBtnText: root.cancelText
    property string confirmBtnText: root.confirmText

    signal confirm()
    signal cancel()

    width: 320
    modal: true
    focus: true
    parent: Overlay.overlay
    x: Math.round((parent.width - width) / 2)
    y: Math.round((parent.height - height) / 2)
    // Popup.CloseOnPressOutsideParent won't work since the parent is the entire screen through Overlay.overlay
    closePolicy: Popup.CloseOnEscape

    // Automatic retranslation properties
    property string titleText: qsTr("Confirm")
    property string descriptionText: qsTr("Are you sure you want to proceed?")
    property string cancelText: qsTr("Cancel")
    property string confirmText: qsTr("OK")

    // Auto-retranslate when language changes
    function retranslateUi() {
        titleText = qsTr("Confirm")
        descriptionText = qsTr("Are you sure you want to proceed?")
        cancelText = qsTr("Cancel")
        confirmText = qsTr("OK")
    }

    background: Rectangle {
        radius: 6
        height: popup.implicitHeight
        color: "#f21f3154"
    }

    contentItem: ColumnLayout {
        id: popupContent

        Text {
            text: popup.title
            font.bold: true
            color: "#ffffff"
        }

        Text {
            text: popup.description
            Layout.fillWidth: true
            Layout.preferredHeight: implicitHeight
            wrapMode: Text.WordWrap
            color: "#ffffff"
        }

        RowLayout {
            spacing: 8
            Layout.fillWidth: true
            Layout.topMargin: 12

            Item {
                Layout.fillWidth: true
            }

            Button {
                text: popup.cancelBtnText
                onClicked: {
                    popup.cancel()
                    popup.close()
                }
            }

            Button {
                text: popup.confirmBtnText
                highlighted: true
                onClicked: {
                    popup.confirm()
                    popup.close()
                }
            }
        }
    }

    // Automatic retranslation on language change
    Connections {
        target: LanguageController
        function onLanguageChanged() {
            console.log("Language changed signal received - auto-retranslating")
            root.retranslateUi()
        }
        function onLanguageLoadFailed(language, reason) {
            console.error("Language load failed:", language, "-", reason)
        }
    }
}
