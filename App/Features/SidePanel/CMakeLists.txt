set(qml_files
    SidePanel.qml
)

qt_add_qml_module(app_features_sidepanel
    URI App.Features.SidePanel
    VERSION 1.0
    QML_FILES ${qml_files}
)
