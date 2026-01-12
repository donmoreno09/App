import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0

Label {
    id: root

    Layout.fillWidth: true
    Layout.leftMargin: Theme.spacing.s3

    color: Theme.colors.text

    font {
        family: Theme.typography.bodySans50Family
        pointSize: Theme.typography.bodySans50Size
        weight: Theme.typography.weightBold
    }
}
