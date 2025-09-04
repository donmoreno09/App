set(qml_files
    MissionPanel.qml
)

qt_add_qml_module(app_features_mission
    URI App.Features.Mission
    VERSION 1.0
    QML_FILES ${qml_files}
    RESOURCE_PREFIX "/"
)
