set(qml_files
    TruckArrivalArrContent.qml
    TruckArrivalCalendarContent.qml
    TruckArrivalCalendarTimeContent.qml
    components/ArrivalStatsCard.qml
    components/DateRangeSelector.qml
    components/DateTimeRangeSelector.qml
)

set(cpp_files
    TruckArrivalController.h
    TruckArrivalController.cpp
    TruckArrivalModel.h
    TruckArrivalModel.cpp
)

qt_add_qml_module(app_features_truckarrival
    URI App.Features.TruckArrival
    VERSION 1.0
    QML_FILES ${qml_files}
    SOURCES ${cpp_files}
    RESOURCE_PREFIX "/"
)

target_link_libraries(app_features_truckarrival
    PRIVATE
        Qt6::Core
        Qt6::Qml
        Qt6::Quick
        Qt6::Network
)
