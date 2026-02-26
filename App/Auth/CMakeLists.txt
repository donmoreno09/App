qt_add_library(app_auth STATIC)

set(cpp_files
    AuthState.h
    AuthManager.h
    AuthManager.cpp
    PermissionManager.h
    PermissionManager.cpp
    SecureTokenStorage.h
    SecureTokenStorage.cpp
)

qt_add_qml_module(app_auth
    URI App.Auth
    VERSION 1.0
    SOURCES ${cpp_files}
)

target_include_directories(app_auth
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}
        ${CMAKE_CURRENT_SOURCE_DIR}/..
)

target_link_libraries(app_auth
    PUBLIC
        Qt6::Qml
    PRIVATE
        app_networking
        Qt6::Core
)
