set(qml_files
    Map.qml
)

qt_add_qml_module(app_features_map
    URI App.Features.Map
    VERSION 1.0
    QML_FILES ${qml_files}
    RESOURCE_PREFIX "/"
)
