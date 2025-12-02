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

qt_generate_deploy_qml_app_script(
    TARGET ${PROJECT_NAME}
    OUTPUT_SCRIPT deploy_script
)

install(TARGETS ${PROJECT_NAME}
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# Install the default configuration template next to the executable
install(FILES ${CMAKE_SOURCE_DIR}/App/config.default.ini
    DESTINATION ${CMAKE_INSTALL_BINDIR}
)

install(SCRIPT ${deploy_script})

install(TARGETS app_logger RUNTIME DESTINATION bin LIBRARY DESTINATION bin)

# Manually add missing MapLibre *.dll and *.qml
set(MAPLIBRE_INSTALL_PREFIX "C:/Qt/6.8.3/msvc2022_64/maplibre-native-qt/install")

install(DIRECTORY
    "${MAPLIBRE_INSTALL_PREFIX}/bin/"
    DESTINATION bin
    FILES_MATCHING
        PATTERN "*.dll"
)

install(DIRECTORY
    "${MAPLIBRE_INSTALL_PREFIX}/qml/MapLibre"
    DESTINATION qml
)

# Enable CPack for creating an installer
include(InstallRequiredSystemLibraries)

# ---- CPack / NSIS settings ----
set(CPACK_GENERATOR "NSIS")

set(CPACK_PACKAGE_NAME ${PROJECT_NAME})
set(CPACK_PACKAGE_VENDOR "Fincantieri NexTech")
set(CPACK_PACKAGE_VERSION "${PROJECT_VERSION}")
set(CPACK_PACKAGE_INSTALL_DIRECTORY ${PROJECT_NAME})
set(CPACK_PACKAGE_EXECUTABLES "${PROJECT_NAME}" "IRIDESS")

# What the user sees in the installer window
set(CPACK_NSIS_PACKAGE_NAME "${PROJECT_NAME} - ${CPACK_PACKAGE_VENDOR}")
set(CPACK_NSIS_DISPLAY_NAME "${PROJECT_NAME} by ${CPACK_PACKAGE_VENDOR}")

include(CPack)
