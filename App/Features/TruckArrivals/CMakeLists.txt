set(qml_files
    components/StatCard.qml

    contents/SidePanelArrivalContent.qml
    contents/SidePanelDateContent.qml
    contents/SidePanelDateTimeContent.qml

    panels/ArrivalsCountPanel.qml
    panels/ArrivalsDatePanel.qml
    panels/ArrivalsDateTimePanel.qml
)

set(cpp_sources
    TruckArrivalController.cpp
    TruckArrivalController.h
    services/TruckArrivalService.cpp
    services/TruckArrivalService.h
)

qt_add_qml_module(app_features_truckarrivals
    URI App.Features.TruckArrivals
    VERSION 1.0
    QML_FILES ${qml_files}
    SOURCES ${cpp_sources}
    RESOURCE_PREFIX "/"
)
