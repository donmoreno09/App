/*!
    \qmltype AlertBanner
    \inqmlmodule App.Components
    \brief Themed alert banner with icon, title, and optional message.

    Displays a prominent inline notification banner used for form-level
    feedback (e.g. authentication errors, warnings, success states).

    The component mirrors the variant pattern used by Input and Button:
    a variant int selects a pre-built AlertBannerStyle object that
    controls all colors, so call-sites stay declarative.

    Usage:
    \code
    UI.AlertBanner {
        Layout.fillWidth: true
        visible: root.hasError
        variant: UI.AlertBannerStyles.Error
        title:   qsTr("The credentials you entered are invalid.")
        message: qsTr("Please enter valid credentials and try again.")
    }
    \endcode
*/

import QtQuick 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI

Item {
    id: root

    // ── Public API ──────────────────────────────────────────────────────────
    property int    variant: UI.AlertBannerStyles.Error
    property string title:   ""
    property string message: ""

    // ── Internals ───────────────────────────────────────────────────────────
    property UI.AlertBannerStyle _style: UI.AlertBannerStyles.fromVariant(variant)

    // implicitHeight grows with content; width is always set by the parent
    // (Layout.fillWidth: true at call-site).
    // Never drive implicitWidth from a RowLayout/ColumnLayout whose Text children
    // are unconstrained — that creates a circular dependency that prevents wrapping
    // and causes the item to overflow its container.
    implicitHeight: _contentRow.implicitHeight + Theme.spacing.s3 * 2 + Theme.borders.b2

    // ── Background ───────────────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color:        root._style.backgroundColor
        radius:       Theme.radius.xs
        border.width: Theme.borders.b1
        border.color: root._style.borderColor
    }

    // ── Content ──────────────────────────────────────────────────────────────
    RowLayout {
        id: _contentRow
        anchors {
            left:         parent.left
            right:        parent.right
            top:          parent.top
            leftMargin:   Theme.spacing.s3
            rightMargin:  Theme.spacing.s3
            topMargin:    Theme.spacing.s3
        }
        spacing: Theme.spacing.s2

        // Icon — fixed size, pinned to top of text block
        Text {
            Layout.alignment: Qt.AlignTop
            text:             root._style.iconText
            color:            Theme.colors.white
            font.family:      Theme.typography.familySans
            font.pointSize:   Theme.typography.bodySans150LightSize
            font.weight:      Theme.typography.weightMedium
        }

        // Text block — fills all remaining width so word-wrap works correctly
        ColumnLayout {
            Layout.fillWidth: true
            spacing:          Theme.spacing.s1

            Text {
                Layout.fillWidth: true
                visible:          root.title !== ""
                text:             root.title
                color:            root._style.titleColor
                wrapMode:         Text.WordWrap
                font.family:      Theme.typography.familySans
                font.pointSize:   Theme.typography.bodySans25Size
                font.weight:      Theme.typography.weightSemibold
            }

            Text {
                Layout.fillWidth: true
                visible:          root.message !== ""
                text:             root.message
                color:            root._style.messageColor
                wrapMode:         Text.WordWrap
                font.family:      Theme.typography.familySans
                font.pointSize:   Theme.typography.bodySans15Size
            }
        }
    }

    // ── Bottom accent bar — rendered last so it draws on top of the border ───
    Rectangle {
        anchors {
            left:         parent.left
            right:        parent.right
            bottom:       parent.bottom
            leftMargin:   Theme.borders.b1
            rightMargin:  Theme.borders.b1
            bottomMargin: Theme.borders.b1
        }
        height: Theme.borders.b2
        radius: Theme.radius.xs
        color:  root._style.accentColor
    }
}
