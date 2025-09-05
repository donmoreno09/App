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



install(TARGETS ${PROJECT_NAME}
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
