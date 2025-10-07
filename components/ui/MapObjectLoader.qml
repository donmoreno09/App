import QtQuick 6.8
import QtLocation 6.8

/*!
    \qmltype MapObjectLoader
    \brief Dynamically creates a map object (i.e. map item).

    Initially, the Loader component was used, however, it creates
    a layer of separation between Map and the loaded component causing
    the loaded map item to not show and work properly within Map.

    To mitigate this, the map item is instead created dynamically with
    `Qt.createComponent` setting its parent to a `MapItemGroup` which,
    as you can see below, has the id of `loader`.

    Now instead of: Map -> Loader -> MapItemComponent
    We have: Map -> MapItemGroup -> MapItemComponent

    I am skipping a lot more details here like there might be more
    Map-related components before we get to MapItemComponent. What's
    important is that MapItemComponent is wrapped around Map-related
    components so that Map can render and handle them properly.

    When I say Map-related components, I am referring to MapQuickItem,
    MapCircle, MapRectangle, MapItemGroup, MapItemView, etc.

    \sa https://doc.qt.io/qt-6/location-maps-qml.html#maps
*/
MapItemGroup {
    id: loader

    // DO NOT put required properties nor do:
    //     property variant modelData
    //     required property variant modelData
    //
    // It will mess up with the QMLContext and it will
    // detach the original modelData preventing it
    // to be modified by this component's children.
    //
    // The documentation's recommendation is to use
    // required properties but as of how the current
    // architecture is, for now we don't and therefore
    // the warning above not to put required properties.
    //
    // See:
    // - Models and Views in Qt Quick (https://doc.qt.io/qt-6/qtquick-modelviewsdata-modelview.html)
    // - Using C++ Models with Qt Quick Views (https://doc.qt.io/qt-6/qtquick-modelviewsdata-cppmodels.html)
    // - Model/View Programming (https://doc.qt.io/qt-6/model-view-programming.html)
    property string source
    property string color
    property string bgColor

    /*!
        \qmlproperty MapItemGroup MapObjectLoader::item
        \brief The loaded map item component. It remains `null`
               if loading fails.

        The `item` property and the `loaded` signal can be used
        together to set slots on the signals of the loaded item.

        For example:
            MapObjectLoader: {
                onLoaded: {
                    item.<signal>.connect(function () { ... })
                }
            }
    */
    property var item: null

    signal loaded()

    Component.onCompleted: {
        const component = Qt.createComponent(loader.source)

        loader.item = component.createObject(loader, {
            map: mapView,
            color: loader.color,
            bgColor: loader.bgColor
        })

        loader.loaded()
    }
}
