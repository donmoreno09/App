import QtQuick 6.8
import QtLocation 6.8
import QtPositioning 6.8

import ".."

BaseMode {
    signal coordChanged()

    // These signals don't reflect the actual properties radiusA and radiusB
    // otherwise setting those properties will invoke a binding loop.
    // The coord changed does reflect since it's not the entire coord changing
    // in its case so it's fine.
    signal majorAxisChanged()
    signal minorAxisChanged()
}
