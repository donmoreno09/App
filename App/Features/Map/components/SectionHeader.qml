import QtQuick 6.8
import QtQuick.Controls 6.8

import App.Themes 1.0

Label {
    color: Theme.colors.text
    verticalAlignment: Text.AlignVCenter
    font {
        family: Theme.typography.bodySans50Family
        pointSize: Theme.typography.bodySans50Size
        weight: Theme.typography.bodySans50Weight
    }
}
