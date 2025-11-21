set(qml_files
    PoiPanel.qml

    components/AreaForm.qml
    components/AreaButton.qml
    components/RectangleForm.qml
    components/EllipseForm.qml
    components/PolygonForm.qml
    components/PointForm.qml
    MOCPoiPanel.qml
    CraneVideoContainer.qml
    CraneTelemetry.qml
    CraneLiftedLoads.qml
)

set(cpp_files
    internals/CsvTableModel.h
    internals/CsvTableModel.cpp
)

qt_add_qml_module(app_features_poi
    URI App.Features.Poi
    VERSION 1.0
    QML_FILES ${qml_files}
    SOURCES ${cpp_files}
    RESOURCE_PREFIX "/"
)

target_include_directories(app_features_poi
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/internals
)

target_link_libraries(app_features_poi
    PRIVATE
        Qt6::Quick
        Qt6::Location
        Qt6::Positioning
        Qt6::Concurrent
)
