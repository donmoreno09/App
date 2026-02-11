qt_add_library(app_networking STATIC)

set(cpp_files
    HttpClient.h
    HttpClient.cpp

    apis/ApiTypes.h
    apis/BaseApi.h
    apis/PoiApi.h
    apis/PoiApi.cpp
    apis/AlertZoneApi.h
    apis/AlertZoneApi.cpp
    apis/AuthApi.h
    apis/AuthApi.cpp

    # TODO: Adhoc solution, need to turn
    #       connections into its own module or
    #       move these in this module.
    ../connections/ApiEndpoints.h
    ../connections/ApiEndpoints.cpp
)

qt_add_qml_module(app_networking
    URI App.Networking
    VERSION 1.0
    SOURCES ${cpp_files}
)

target_include_directories(app_networking
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}
)

target_include_directories(app_networking
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/..   # points to App/ (contains entities/, etc.)
)

target_link_libraries(app_networking
    PRIVATE
        Qt6::Core
        Qt6::Gui
)
