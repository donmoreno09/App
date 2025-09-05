cmake_minimum_required(VERSION 3.16)

project(IRIDESS_FE VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.8 REQUIRED
    COMPONENTS
        Gui
        Qml
        Quick
        Positioning
        WebEngineQuick
        Mqtt
        LinguistTools
        QuickTest
)

qt_standard_project_setup(REQUIRES 6.8)

enable_testing()

add_subdirectory(App)

# Define translation files
set(TS_FILES
    translations/app_en.ts
    translations/app_it.ts
)

# Create translations directory if it doesn't exist
file(MAKE_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/translations)

# Add translation support - this handles EVERYTHING automatically:
# - Runs lupdate to extract qsTr() calls from source files
# - Runs lrelease to compile .ts files to .qm files
# - Embeds .qm files as resources in the executable
qt6_add_translations(${PROJECT_NAME}
    TS_FILES ${TS_FILES}
    RESOURCE_PREFIX "/translations"
    QM_FILES_OUTPUT_VARIABLE qm_files
)


install(TARGETS ${PROJECT_NAME}
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
