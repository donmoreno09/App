set(qml_files
    LoginPage.qml
)

qt_add_qml_module(app_features_auth
    URI App.Features.Auth
    VERSION 1.0
    QML_FILES ${qml_files}
    RESOURCE_PREFIX "/"
)

target_link_libraries(app_features_auth
    PRIVATE
        Qt6::Quick
        Qt6::Gui
        Qt6::Qml
)
