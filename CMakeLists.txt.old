cmake_minimum_required(VERSION 3.16)

project(Sanbdox VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.8 REQUIRED COMPONENTS Widgets Quick Positioning WebEngineQuick Mqtt LinguistTools)
find_package(Qt6 REQUIRED COMPONENTS Core)


set(PROJECT_SOURCES
    components/main.qml

    core/popupmanager.h core/popupmanager.cpp
    core/geoselectionutils.h
    layers/baselayer.h layers/baselayer.cpp
    layers/basemaplayer.h layers/basemaplayer.cpp
    main.cpp
    resources.qrc
    layers/trackmaplayer.h layers/trackmaplayer.cpp
    core/layermanager.h core/layermanager.cpp
    assets/layers.json
    core/interactionmodemanager.h core/interactionmodemanager.cpp


    layers/staticpoimaplayer.h layers/staticpoimaplayer.cpp
    layers/annotationmaplayer.h layers/annotationmaplayer.cpp
    core/thirdparty/ShipArrivalController.h core/thirdparty/ShipArrivalController.cpp
    core/thirdparty/TrailersPredictionsController.h core/thirdparty/TrailersPredictionsControler.cpp
    core/variantlistmodel.h core/variantlistmodel.cpp
)

qt_add_executable(Sanbdox
    MANUAL_FINALIZATION
    ${PROJECT_SOURCES}
    connections/httpclient.h connections/httpclient.cpp
    persistence/ipersistable.h
    persistence/ipersistencemanager.h
    persistence/persistencemanagerbase.h persistence/persistencemanagerbase.cpp
    persistence/poipersistencemanager.h persistence/poipersistencemanager.cpp
    persistence/shapepersistencemanager.h persistence/shapepersistencemanager.cpp
    connections/apiendpoints.h
    models/poi.h
    models/shape.h
    models/geometry.h
    controllers/poicontroller.h controllers/poicontroller.cpp
    controllers/poioptionscontroller.h controllers/poioptionscontroller.cpp
    events/selectionboxbus.h
    controllers/shapecontroller.h controllers/shapecontroller.cpp
    connections/mqtt/mqttclientservice.h connections/mqtt/mqttclientservice.cpp
    connections/mqtt/parser/imessageparser.h
    connections/mqtt/parser/simpletrackparser.h
    core/legacy/clock.h core/legacy/clock.cpp
    core/legacy/registertemplate.h
    controllers/radialmenucontroller.h
    controllers/radialmenucontroller.cpp
    core/legacy/enums/econtrollers.h core/legacy/enums/econtrollers.cpp
    core/legacy/enums/eservice.h core/legacy/enums/eservice.cpp
    enums/etrackstate.h enums/etrackstate.cpp
    enums/etrackstate.h enums/etrackstate.cpp
    models/metadata/metadataentry.h
    models/metadata/notemetadataentry.h
    models/details.h
    models/radial-menu/radialmenunode.h
    models/radial-menu/propertytreenode.h
    models/radial-menu/radialmenunode.cpp
    models/radial-menu/propertytreenode.cpp
    core/trackmanager.h core/trackmanager.cpp
    App/Features/language/LanguageController.h App/features/language/LanguageController.cpp
    App/Features/language/LanguageEnum.h App/features/language/LanguageEnum.cpp
)

target_link_libraries(Sanbdox PRIVATE
    Qt6::Widgets
    Qt6::Quick
    Qt6::Positioning
    Qt6::WebEngineQuick
    Qt6::Mqtt

)
target_link_libraries(Sanbdox PRIVATE Qt6::Core)

set_target_properties(Sanbdox PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.Sanbdox
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

include(GNUInstallDirs)
install(TARGETS Sanbdox
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# Add translation files
set(TS_FILES
    translations/app_en.ts
    translations/app_it.ts
)

qt_add_translations(Sanbdox
    TS_FILES ${TS_FILES}
    RESOURCE_PREFIX "/translations"
)

qt_finalize_executable(Sanbdox)
