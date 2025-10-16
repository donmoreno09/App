set(qml_files
    MapHost.qml
    MapTilesetsPanel.qml
    MapTilesetsItem.qml
    internals/Map.qml
    internals/MapState.qml
)

set(qml_singletons
    MapController.qml
    MapPlugins.qml
)

set_source_files_properties(
    ${qml_singletons}
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE
)

set(cpp_files
    PluginProbe.h
)

qt_add_qml_module(app_features_map
    URI App.Features.Map
    VERSION 1.0
    QML_FILES
        ${qml_files}
        ${qml_singletons}
    SOURCES ${cpp_files}
    RESOURCE_PREFIX "/"
)

include(GenerateExportHeader)
generate_export_header(app_features_map
  EXPORT_FILE_NAME ${CMAKE_CURRENT_SOURCE_DIR}/app_features_map_export.h)

target_link_libraries(app_features_map
    PRIVATE
        Qt6::Gui
        Qt6::Qml
        Qt6::Quick
        Qt6::Location
        Qt6::Positioning
)
