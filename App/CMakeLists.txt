qt_add_executable(${PROJECT_NAME}
    main.cpp
)

file(GLOB_RECURSE APP_ASSETS
    RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}"
    CONFIGURE_DEPENDS
    "${CMAKE_CURRENT_SOURCE_DIR}/assets/*.*"
)

file(GLOB_RECURSE APP_SOURCES
    RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}"
    CONFIGURE_DEPENDS
    "${CMAKE_CURRENT_SOURCE_DIR}/*.qml"
    "${CMAKE_CURRENT_SOURCE_DIR}/Components/*.qml"
    "${CMAKE_CURRENT_SOURCE_DIR}/Features/*.qml"
    "${CMAKE_CURRENT_SOURCE_DIR}/Playground/*.qml"
    "${CMAKE_CURRENT_SOURCE_DIR}/StubComponents/*.qml"
    "${CMAKE_CURRENT_SOURCE_DIR}/Themes/*.qml"
)

qt_add_qml_module(${PROJECT_NAME}
    URI App
    VERSION 1.0
    QML_FILES
        Main.qml
    RESOURCE_PREFIX "/" # For more info: https://doc.qt.io/qt-6/qt-add-qml-module.html#resource-prefix
    RESOURCES
        ${APP_ASSETS}
)

add_subdirectory(Components)
add_subdirectory(StubComponents)
add_subdirectory(Features)
add_subdirectory(Playground)
add_subdirectory(Themes)

target_link_libraries(${PROJECT_NAME}
    PRIVATE
        Qt6::Gui
        Qt6::Qml
        Qt6::Quick
        app_features_language
)

# Translation setup
set(TS_FILES
    ${CMAKE_SOURCE_DIR}/translations/app_en.ts
    ${CMAKE_SOURCE_DIR}/translations/app_it.ts
)

qt_add_translations(${PROJECT_NAME} 
    TS_FILES ${TS_FILES} 
    SOURCES ${APP_SOURCES}
    RESOURCE_PREFIX "/translations"
)

# Ensure translations are compiled before the main target
add_dependencies(${PROJECT_NAME}
    ${PROJECT_NAME}_lupdate
    ${PROJECT_NAME}_lrelease
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
