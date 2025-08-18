import QtQuick 6.8
import QtLocation 6.8
import "../../"

MapItemGroup {
    id: baseRoot
    property Map map
    // couple this for now for the poi editors and poi popups to be able to work together
    property WMSMapLayer wms

    Component.onCompleted: {
        console.log("Loaded " + baseRoot.objectName)
    }

    Component.onDestruction: {
        console.log("Destroying " + baseRoot.objectName)
        map.removeMapItemGroup(baseRoot)
    }
}
