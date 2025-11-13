set(qml_files
)

qt_add_qml_module(app_stubcomponents
    URI App.StubComponents
    VERSION 1.0
    QML_FILES ${qml_files}
    RESOURCE_PREFIX "/"
)
