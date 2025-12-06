import QtQuick 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Features.Language 1.0

Text {
    id: root

    property string sectionTitle: ""

    visible: text !== ""
    text: `${TranslationManager.revision}` && sectionTitle
    color: Theme.colors.text
    font.family: Theme.typography.bodySans25StrongFamily
    font.pointSize: Theme.typography.bodySans25StrongSize
    font.weight: Theme.typography.weightBold
    Layout.topMargin: Theme.spacing.s4
}
