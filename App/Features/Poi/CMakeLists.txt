set(qml_files
    PoiPanel.qml
    MOCPoiPanel.qml
    GoliathVideoContainer.qml
    GoliathDataCsv.qml
    GoliathLiftedLoads.qml
)

set(cpp_files
)

qt_add_qml_module(app_features_poi
    URI App.Features.Poi
    VERSION 1.0
    QML_FILES ${qml_files}
    SOURCES ${cpp_files}
    RESOURCE_PREFIX "/"
)

target_link_libraries(app_features_poi
    PRIVATE
        Qt6::Quick
        Qt6::Location
        Qt6::Positioning
)
