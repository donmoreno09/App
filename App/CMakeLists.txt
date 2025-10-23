
cmake_minimum_required(VERSION 3.16)
project(${PROJECT_NAME} VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

# Imposta Release come default
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()

find_package(Qt6 REQUIRED COMPONENTS Quick Location)
qt_standard_project_setup(REQUIRES 6.8)

# Percorsi MapLibre
set(MAPLIBRE_ROOT "C:/Qt/maplibre-native-qt")
set(MAPLIBRE_INCLUDE_DIR "${MAPLIBRE_ROOT}/vendor/maplibre-native/include")

# Usa Release o Debug in base alla configurazione
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(MAPLIBRE_LIB_DIR "${MAPLIBRE_ROOT}/build/src/core/Debug")
    set(MAPLIBRE_LIB_NAME "QMapLibred")
    set(MAPLIBRE_DLL_NAME "QMapLibred.dll")
else()
    set(MAPLIBRE_LIB_DIR "${MAPLIBRE_ROOT}/build/src/core")
    set(MAPLIBRE_LIB_NAME "QMapLibre")
    set(MAPLIBRE_DLL_NAME "QMapLibre.dll")
endif()

# Trova la libreria
find_library(MAPLIBRE_LIB
    NAMES ${MAPLIBRE_LIB_NAME}
    PATHS "${MAPLIBRE_LIB_DIR}"
    NO_DEFAULT_PATH
)


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
    map-objects/Track.qml
    map-objects/Tir.qml
    map-objects/TriangleHeading.qml

    # Layers
    layers/AISTrackMapLayer.qml
    layers/DocSpaceTrackMapLayer.qml
    layers/TirTrackMapLayer.qml
    layers/LayersPanel.qml
)

set(cpp_sources
    # Connections
    connections/mqtt/parser/IMessageParser.h
    connections/mqtt/parser/TrackParser.h
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
    core/popupmanager.cpp
    core/popupmanager.h
    core/TrackManager.cpp
    core/TrackManager.h
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
    layers/BaseTrackMapLayer.cpp
    layers/BaseTrackMapLayer.h
    layers/TrackMapLayer.cpp
    layers/TrackMapLayer.h
    layers/TirMapLayer.cpp
    layers/TirMapLayer.h

    # Entities
    entities/metadata/MetadataEntry.h
    entities/metadata/NoteMetadataEntry.h
    entities/Details.h
    entities/Geometry.h
    entities/Poi.h
    entities/shape.h
    entities/BaseTrack.h
    entities/Track.h
    entities/Tir.h
    entities/Velocity.h


    # Qt Models
    models/ModelHelper.h
    models/ModelHelper.cpp
    models/PoiModel.cpp
    models/PoiModel.h
    models/BaseTrackModel.h
    models/TrackModel.cpp
    models/TrackModel.h
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
        ${MAPLIBRE_LIB}
)

target_include_directories(${PROJECT_NAME}
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/connections
        ${CMAKE_CURRENT_SOURCE_DIR}/connections/mqtt
        ${CMAKE_CURRENT_SOURCE_DIR}/core
        ${CMAKE_CURRENT_SOURCE_DIR}/events
        ${CMAKE_CURRENT_SOURCE_DIR}/layers
        ${CMAKE_CURRENT_SOURCE_DIR}/models
        ${MAPLIBRE_INCLUDE_DIR}
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



# Copia DLL MapLibre
if(WIN32 AND EXISTS "${MAPLIBRE_LIB_DIR}/${MAPLIBRE_DLL_NAME}")
    add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${MAPLIBRE_LIB_DIR}/${MAPLIBRE_DLL_NAME}"
        $<TARGET_FILE_DIR:${PROJECT_NAME}>
    )
    message(STATUS "Will copy ${MAPLIBRE_DLL_NAME}")

    # Copia anche tutte le altre DLL nella cartella
    file(GLOB MAPLIBRE_DLLS "${MAPLIBRE_LIB_DIR}/*.dll")
    foreach(dll_file ${MAPLIBRE_DLLS})
        get_filename_component(dll_name ${dll_file} NAME)
        add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "${dll_file}"
            $<TARGET_FILE_DIR:${PROJECT_NAME}>
        )
    endforeach()
endif()

# Verifica e copia il plugin geoservices se esiste
set(MAPLIBRE_PLUGIN_DIR "${MAPLIBRE_ROOT}/build/src/location/plugins/geoservices")
if(EXISTS "${MAPLIBRE_PLUGIN_DIR}")
    message(STATUS "MapLibre plugin directory found: ${MAPLIBRE_PLUGIN_DIR}")

    # Crea la directory per i plugin
    add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E make_directory
        $<TARGET_FILE_DIR:${PROJECT_NAME}>/plugins/geoservices
    )

    # Copia i plugin
    file(GLOB PLUGIN_DLLS "${MAPLIBRE_PLUGIN_DIR}/*.dll")
    foreach(plugin_dll ${PLUGIN_DLLS})
        get_filename_component(plugin_name ${plugin_dll} NAME)
        message(STATUS "Will copy plugin: ${plugin_name}")
        add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "${plugin_dll}"
            $<TARGET_FILE_DIR:${PROJECT_NAME}>/plugins/geoservices/
        )
    endforeach()
endif()

include(GNUInstallDirs)
install(TARGETS ${PROJECT_NAME}
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
