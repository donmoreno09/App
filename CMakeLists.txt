cmake_minimum_required(VERSION 3.16)

project(IRIDESS_FE VERSION 0.1 LANGUAGES CXX)

set(QT_QML_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}")
set(QML_IMPORT_PATH "${QT_QML_OUTPUT_DIRECTORY}" CACHE PATH "Extra QML import paths")

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.8 REQUIRED
    COMPONENTS
        Gui
        Qml
        Quick
        Location
        Positioning
        WebEngineQuick
        Mqtt
        LinguistTools
        QuickTest
        Sql
)
find_package(QMapLibre COMPONENTS Location REQUIRED)

qt_standard_project_setup(REQUIRES 6.8)

enable_testing()

add_subdirectory(App)

target_include_directories(${PROJECT_NAME} PUBLIC ${CMAKE_SOURCE_DIR})

install(TARGETS ${PROJECT_NAME}
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
