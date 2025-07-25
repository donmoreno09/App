import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15


Popup {
    id: popup

    property string title: ""
    property string description: ""
    property string cancelBtnText: "Cancel"
    property string confirmBtnText: "OK"

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
}
