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

    # Map Objects
    map-objects/AlertZoneEllipse.qml
    map-objects/AlertZonePolygon.qml
    map-objects/AlertZoneRectangle.qml
    map-objects/Track.qml
    map-objects/Tir.qml
    map-objects/TriangleHeading.qml
    map-objects/PoiPoint.qml
    map-objects/PoiRectangle.qml
    map-objects/PoiEllipse.qml
    map-objects/PoiPolygon.qml
    map-objects/MOCPoiPoint.qml

    # Layers
    layers/AlertZoneMapLayer.qml
    layers/BaseMapLayer.qml
    layers/AISTrackMapLayer.qml
    layers/DocSpaceTrackMapLayer.qml
    layers/TirTrackMapLayer.qml
    layers/LayersPanel.qml
    layers/PoiMapLayer.qml
    layers/MOCPoIStaticLayer.qml
)

set(cpp_sources
    # Connections
    connections/mqtt/parser/IMessageParser.h
    connections/mqtt/parser/TrackParser.h
    connections/mqtt/parser/TruckNotificationParser.h
    connections/mqtt/parser/TirParser.h
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
    core/TrackManager.cpp
    core/TrackManager.h
    core/PoiOptions.h
    core/PoiOptions.cpp

    # Layers
    layers/AlertZoneMapLayerController.h
    layers/AlertZoneMapLayerController.cpp
    layers/AnnotationMapLayer.cpp
    layers/AnnotationMapLayer.h
    layers/BaseLayer.cpp
    layers/BaseLayer.h
    layers/BaseMapLayer.cpp
    layers/BaseMapLayer.h
    layers/Layers.h
    layers/PoiMapLayerController.cpp
    layers/PoiMapLayerController.h
    layers/BaseTrackMapLayer.cpp
    layers/BaseTrackMapLayer.h
    layers/TrackMapLayer.cpp
    layers/TrackMapLayer.h
    layers/TirMapLayer.cpp
    layers/TirMapLayer.h

    # Entities
    entities/AlertZone.h
    entities/metadata/MetadataEntry.h
    entities/metadata/NoteMetadataEntry.h
    entities/AlertZone.h
    entities/Details.h
    entities/Geometry.h
    entities/Poi.h
    entities/shape.h
    entities/BaseTrack.h
    entities/Track.h
    entities/TruckNotification.h
    entities/Tir.h
    entities/Velocity.h


    # Qt Models
    models/AlertZoneModel.h
    models/AlertZoneModel.cpp
    models/ModelHelper.h
    models/ModelHelper.cpp
    models/CoordinatesModel.h
    models/PoiModel.cpp
    models/PoiModel.h
    models/BaseTrackModel.h
    models/TrackModel.cpp
    models/TrackModel.h
    models/TruckNotificationModel.h
    models/TruckNotificationModel.cpp
    models/TirModel.cpp
    models/TirModel.h

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
    RESOURCES
        ${APP_ASSETS}
        config/mqtt_config.json
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
        Qt6::Network
        Qt6::Concurrent
        Qt6::WebEngineQuick
        Qt6::WebEngineCore
        QMapLibre::Location
)

qmaplibre_location_setup_plugins(${PROJECT_NAME})

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
