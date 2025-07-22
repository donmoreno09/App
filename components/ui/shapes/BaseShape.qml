import QtQuick 2.15
import QtQuick.Shapes 2.15
import QtLocation 6.8
import QtPositioning 6.8

import raise.singleton.interactionmanager 1.0
import raise.singleton.controllers 1.0

import "../../"

MapItemGroup {
    id: root

    // DO NOT put required properties nor do:
    //     property variant modelData
    //     required property variant modelData
    //
    // It will mess up with the QMLContext and it will
    // detach the original modelData preventing it
    // to be modified by this component's children.
    //
    // See:
    // - Models and Views in Qt Quick (https://doc.qt.io/qt-6/qtquick-modelviewsdata-modelview.html)
    // - Using C++ Models with Qt Quick Views (https://doc.qt.io/qt-6/qtquick-modelviewsdata-cppmodels.html)
    // - Model/View Programming (https://doc.qt.io/qt-6/model-view-programming.html)
    property Map map

    property string color
    property string bgColor

    signal modified()

    function getModelData() {
        return modelData
    }

    function syncModelData(newModelData) {
        modelData = newModelData
    }
}
