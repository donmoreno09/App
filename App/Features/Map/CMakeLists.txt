set(qml_files
    Map.qml
)

set(qml_singletons
    MapController.qml
)

set_source_files_properties(
    ${qml_singletons}
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE
)

qt_add_qml_module(app_features_map
    URI App.Features.Map
    VERSION 1.0
    QML_FILES
        ${qml_files}
        ${qml_singletons}
    RESOURCE_PREFIX "/"
)

target_link_libraries(app_features_map
    PRIVATE
        Qt6::Quick
)
