import QtQuick 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Features.Language 1.0

Text {
    text: `${TranslationManager.revision}` && qsTr("No notifications")
    color: Theme.colors.textMuted
    font.family: Theme.typography.bodySans25Family
    font.pointSize: Theme.typography.bodySans25Size
    Layout.alignment: Qt.AlignHCenter
    Layout.topMargin: Theme.spacing.s8
}
