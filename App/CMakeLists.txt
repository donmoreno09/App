qt_add_executable(${PROJECT_NAME}
    main.cpp
)

file(GLOB_RECURSE APP_ASSETS
    RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}"
    CONFIGURE_DEPENDS
    "${CMAKE_CURRENT_SOURCE_DIR}/assets/*.*"
)

set(qml_files
    Main.qml

    # Layers
    layers/AISTrackMapLayer.qml
)

set(cpp_sources
    # Config
    config/mqtt_config.json

    # Connections
    connections/mqtt/parser/IMessageParser.h
    connections/mqtt/parser/TrackParser.h
    connections/mqtt/MqttClientService.cpp
    connections/mqtt/MqttClientService.h
    connections/apiendpoints.h
    connections/httpclient.cpp
    connections/httpclient.h

    # Core
    core/GeoSelectionUtils.h
    core/interactionmodemanager.cpp
    core/interactionmodemanager.h
    core/LayerManager.cpp
    core/LayerManager.h
    core/popupmanager.cpp
    core/popupmanager.h
    core/trackmanager.cpp
    core/trackmanager.h
    core/variantlistmodel.cpp
    core/variantlistmodel.h

    # Events
    events/selectionboxbus.h

    # Layers
    layers/AnnotationMapLayer.cpp
    layers/AnnotationMapLayer.h
    layers/BaseLayer.cpp
    layers/BaseLayer.h
    layers/BaseMapLayer.cpp
    layers/BaseMapLayer.h
    layers/Layers.h
    layers/PoiMapLayer.cpp
    layers/PoiMapLayer.h
    layers/TrackMapLayer.cpp
    layers/TrackMapLayer.h

    # Entities
    entities/metadata/MetadataEntry.h
    entities/metadata/NoteMetadataEntry.h
    entities/Details.h
    entities/Geometry.h
    entities/Poi.h
    entities/shape.h
    entities/Track.h

    # Qt Models
    models/PoiModel.cpp
    models/PoiModel.h
    models/TrackModel.cpp
    models/TrackModel.h

    # Persistence
    persistence/ipersistable.h
    persistence/ipersistencemanager.h
    persistence/persistencemanagerbase.cpp
    persistence/persistencemanagerbase.h
    persistence/poipersistencemanager.cpp
    persistence/poipersistencemanager.h
    persistence/shapepersistencemanager.cpp
    persistence/shapepersistencemanager.h
)

qt_add_qml_module(${PROJECT_NAME}
    URI App
    VERSION 1.0
    QML_FILES ${qml_files}
    SOURCES ${cpp_sources}
    RESOURCE_PREFIX "/" # For more info: https://doc.qt.io/qt-6/qt-add-qml-module.html#resource-prefix
    RESOURCES ${APP_ASSETS}
)

add_subdirectory(Components)
add_subdirectory(StubComponents)
add_subdirectory(Features)
add_subdirectory(Playground)
add_subdirectory(Themes)
add_subdirectory(Logger)

target_link_libraries(${PROJECT_NAME}
    PRIVATE
        app_logger
)

target_link_libraries(${PROJECT_NAME}
    PRIVATE
        Qt6::Gui
        Qt6::Qml
        Qt6::Quick
        Qt6::Sql
        Qt6::Mqtt
        Qt6::Location
        Qt6::Positioning
)

target_include_directories(${PROJECT_NAME}
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/connections
        ${CMAKE_CURRENT_SOURCE_DIR}/connections/mqtt
        ${CMAKE_CURRENT_SOURCE_DIR}/core
        ${CMAKE_CURRENT_SOURCE_DIR}/events
        ${CMAKE_CURRENT_SOURCE_DIR}/layers
        ${CMAKE_CURRENT_SOURCE_DIR}/models
)

# Translation setup
set(TS_FILES
    ${CMAKE_SOURCE_DIR}/translations/app_en.ts
    ${CMAKE_SOURCE_DIR}/translations/app_it.ts
)

qt_add_translations(${PROJECT_NAME}
    TS_FILES ${TS_FILES}
    RESOURCE_PREFIX "/translations"
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(${PROJECT_NAME} PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.apptheming
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)
