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
            color: "#ffffff"  // Changed to white
            font: control.font
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }

        highlighted: control.highlightedIndex === index

        background: Rectangle {
            anchors.fill: parent
            color: delegate.highlighted ? "#404040" : "#2a2a2a"  // Dark theme colors
            radius: 4
        }
    }

    indicator: Text {
        text: "\u25BE" // ▼
        color: "#ffffff"  // Changed to white
        font.pixelSize: 12
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 8
    }

    contentItem: Text {
        leftPadding: 8  // Increased padding
        rightPadding: control.indicator.width + control.spacing
        text: control.displayText
        font: control.font
        color: "#ffffff"  // Changed to white
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        implicitWidth: 120
        implicitHeight: 28
        color: "#2a2a2a"  // Dark background
        border.color: "#444444"  // Dark border
        border.width: control.visualFocus ? 2 : 1
        radius: 6  // Increased radius to match other inputs
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
            color: "#2a2a2a"  // Dark popup background
            border.color: "#444444"  // Dark border
            border.width: 1
            radius: 6
        }
    }
}
