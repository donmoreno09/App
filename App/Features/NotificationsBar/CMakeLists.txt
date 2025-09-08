set(qml_files
    NotificationsBar.qml
    components/NotificationsItem.qml
    components/NotificationsItemStyle.qml
    components/NotificationsContainer.qml
)

set(qml_singletons
    components/NotificationsItemStyles.qml
)

set_source_files_properties(
    ${qml_singletons}
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE
)

qt_add_qml_module(app_features_notificationsbar
    URI App.Features.NotificationsBar
    VERSION 1.0
    QML_FILES
        ${qml_files}
        ${qml_singletons}
    RESOURCE_PREFIX "/"
)
