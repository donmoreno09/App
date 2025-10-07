import QtQuick 2.15

import raise.singleton.interactionmanager 1.0

TapHandler {
    acceptedButtons: Qt.LeftButton

    onTapped: function (eventPoint) {
        InteractionModeManager.currentSelectedShapeId = modelData.id
        eventPoint.accepted = true
    }
}
