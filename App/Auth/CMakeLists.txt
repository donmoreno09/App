qt_add_library(app_auth STATIC)

set(cpp_files
    AuthState.h
    AuthManager.h
    AuthManager.cpp
    JwtUtils.h
    PermissionManager.h
    PermissionManager.cpp
    SecureTokenStorage.h
    SecureTokenStorage.cpp
)

set(qml_files
    ui/LoginPage.qml
    ui/UserMenuPopup.qml
    ui/LogoutDialog.qml
)

qt_add_qml_module(app_auth
    URI App.Auth
    VERSION 1.0
    SOURCES ${cpp_files}
    QML_FILES ${qml_files}
    RESOURCE_PREFIX "/"
)

target_include_directories(app_auth
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}
)

target_include_directories(app_auth
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/..
)

target_link_libraries(app_auth
    PRIVATE
        Qt6::Core
        Qt6::Qml
        Qt6::Quick
        Qt6::Gui

        app_features_titlebar
        app_networking
        app_logger
)
