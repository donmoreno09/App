set(qml_files
    VesselPanel.qml
)

qt_add_qml_module(app_features_vesselpanel
    URI App.Features.VesselPanel
    VERSION 1.0
    QML_FILES
        ${qml_files}
    RESOURCE_PREFIX "/"
)
