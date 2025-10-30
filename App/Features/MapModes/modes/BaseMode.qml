import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8

MapItemGroup {
    id: root
    anchors.fill: parent

    property string type: "base"

    // For now, this method lives here which
    // helps build the geometry data needed for
    // saving
    function buildGeometry() { console.warn("Build geometry invoked without being overridden."); return {} }
}
