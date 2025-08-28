set(qml_files
    Button.qml
    StubDateTime.qml
    SearchBar.qml
    Title.qml
)

qt_add_qml_module(app_stubcomponents
    URI App.StubComponents
    VERSION 1.0
    QML_FILES ${qml_files}
)
