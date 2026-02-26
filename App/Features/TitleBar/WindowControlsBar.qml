import QtQuick 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Features.TitleBar 1.0

Item {
    id: root

    implicitHeight: Theme.layout.titleBarHeight
    visible: WindowsNcController.isWindows()

    // Drag-to-move the window from any empty spot on the bar
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        onPressed: WindowsNcController.window.startSystemMove()
        onDoubleClicked: WindowsNcController.toggleMaximize()
    }

    RowLayout {
        anchors.fill: parent
        anchors.rightMargin: Theme.spacing.s2
        spacing: Theme.spacing.s2

        Item { Layout.fillWidth: true }  // Push buttons to right

        SystemButton {
            source: "qrc:/App/assets/icons/minus.svg"
            onClicked: WindowsNcController.minimize()
        }

        SystemButton {
            source: "qrc:/App/assets/icons/maximize.svg"
            onClicked: WindowsNcController.toggleMaximize()
        }

        SystemButton {
            source: "qrc:/App/assets/icons/x-close.svg"
            onClicked: WindowsNcController.window.close()
        }
    }
}
