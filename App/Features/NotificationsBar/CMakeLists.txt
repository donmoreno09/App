set(qml_files
    NotificationsBar.qml
)

qt_add_qml_module(app_features_notificationsbar
    URI App.Features.NotificationsBar
    VERSION 1.0
    QML_FILES ${qml_files}
)
