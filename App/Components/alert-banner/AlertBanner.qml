import QtQuick 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI

Item {
    id: root

    property int variant: UI.AlertBannerStyles.Error
    property string title: ""
    property string message: ""

    property UI.AlertBannerStyle _style: UI.AlertBannerStyles.fromVariant(variant)

    implicitHeight: _contentRow.implicitHeight + Theme.spacing.s3 * 2 + Theme.borders.b2

    Rectangle {
        anchors.fill: parent
        color: Theme.colors.input
        radius: Theme.radius.xs
        border.width: Theme.borders.b1
        border.color: root._style.borderColor
    }

    RowLayout {
        id: _contentRow
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            leftMargin: Theme.spacing.s3
            rightMargin: Theme.spacing.s3
            topMargin: Theme.spacing.s3
        }
        spacing: Theme.spacing.s2

        Text {
            Layout.alignment: Qt.AlignTop
            text: root._style.iconText
            color: Theme.colors.white
            font.family: Theme.typography.familySans
            font.pointSize: Theme.typography.bodySans150LightSize
            font.weight: Theme.typography.weightMedium
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.s1

            Text {
                Layout.fillWidth: true
                visible: root.title !== ""
                text: root.title
                color: root._style.titleColor
                wrapMode: Text.WordWrap
                font.family: Theme.typography.familySans
                font.pointSize: Theme.typography.bodySans25Size
                font.weight: Theme.typography.weightSemibold
            }

            Text {
                Layout.fillWidth: true
                visible: root.message !== ""
                text: root.message
                color: root._style.messageColor
                wrapMode: Text.WordWrap
                font.family: Theme.typography.familySans
                font.pointSize: Theme.typography.bodySans15Size
            }
        }
    }

    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: Theme.borders.b1
            rightMargin: Theme.borders.b1
            bottomMargin: Theme.borders.b1
        }
        height: Theme.borders.b4
        radius: Theme.radius.xs
        color: root._style.accentColor
    }
}
