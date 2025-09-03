import QtQuick 6.8
import QtQuick.Layouts 6.8
import QtQuick.Controls 6.8
import App.Themes 1.0

Rectangle {
    color: "transparent"

    Text {
        id: titleText
        anchors.centerIn: parent
        text: TitleController.currentTitle
        color: Theme.colors.text
        font.pointSize: Theme.typography.sizeSm

        // Behavior on text {
        //     SequentialAnimation {
        //         NumberAnimation {
        //             target: titleText
        //             property: "opacity"
        //             to: 0
        //             duration: 150
        //             easing.type: Easing.InOutQuad
        //         }
        //         PropertyAction { target: titleText; property: "text" }
        //         NumberAnimation {
        //             target: titleText
        //             property: "opacity"
        //             to: 1
        //             duration: 150
        //             easing.type: Easing.InOutQuad
        //         }
        //     }
        // }
    }


        Rectangle {
            id: glowRect

            anchors.top: titleText.bottom
            anchors.horizontalCenter: titleText.horizontalCenter
            anchors.topMargin: 4
            width: 16
            height: 4
            topLeftRadius: Theme.radius.sm
            topRightRadius: Theme.radius.sm

            // Smooth glow transition
            // Behavior on opacity {
            //     NumberAnimation {
            //         duration: 200
            //         easing.type: Easing.OutCubic
            //     }
            // }
        }
}
