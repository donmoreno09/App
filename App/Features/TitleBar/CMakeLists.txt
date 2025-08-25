set(qml_files
    TitleBar.qml
)

qt_add_qml_module(app_features_titlebar
    URI App.Features.TitleBar
    VERSION 1.0
    QML_FILES ${qml_files}
)
