set(qml_files
    components/StatCard.qml

    contents/SidePanelArrContent.qml
    contents/SidePanelDateContent.qml
    contents/SidePanelDateTimeContent.qml

    panels/ArrivalsCountPanel.qml
    panels/ArrivalsDatePanel.qml
    panels/ArrivalsDateTimePanel.qml
)

set(cpp_sources
    ShipArrivalController.cpp
    ShipArrivalController.h
    service/ShipArrivalService.cpp
    service/ShipArrivalService.h
)

qt_add_qml_module(app_features_arrivals
    URI App.Features.Arrivals
    VERSION 1.0
    QML_FILES ${qml_files}
    SOURCES ${cpp_sources}
    RESOURCE_PREFIX "/"
    RESOURCES ${icon_resources}
)
