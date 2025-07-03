pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic

ComboBox {
    id: control
    model: ["First", "Second", "Third"]

    delegate: ItemDelegate {
        id: delegate

        required property var model
        required property int index

        width: control.width
        height: 28
        contentItem: Text {
            text: delegate.model[control.textRole]
            color: "black"
            font: control.font
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }

        highlighted: control.highlightedIndex === index
        background: Rectangle {
            anchors.fill: parent
            color: delegate.highlighted ? "#adbed9" : "transparent"
        }
    }

    indicator: Text {
        text: "\u25BE" // ▼
        color: "#878787"
        font.pixelSize: 12
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 8
    }

    contentItem: Text {
        leftPadding: 4
        rightPadding: control.indicator.width + control.spacing

        text: control.displayText
        font: control.font
        color: "black"
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        implicitWidth: 120
        implicitHeight: 28
        border.color: "#888888"
        border.width: control.visualFocus ? 2 : 1
        radius: 2
    }

    popup: Popup {
        y: control.height - 1
        width: control.width
        height: Math.min(contentItem.implicitHeight, control.Window.height - topMargin - bottomMargin)
        padding: 0

        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: control.popup.visible ? control.delegateModel : null
            currentIndex: control.highlightedIndex

            ScrollIndicator.vertical: ScrollIndicator { }
        }

        background: Rectangle {
            border.color: "#888888"
            radius: 2
        }
    }
}
