set(qml_files
    ContextPanel.qml
)

qt_add_qml_module(app_features_contextpanel
    URI App.Features.ContextPanel
    VERSION 1.0
    QML_FILES ${qml_files}
    RESOURCE_PREFIX "/"
)
