set(qml_files
    ButtonsTest.qml
)

qt_add_qml_module(app_tests
    URI App.Tests
    VERSION 1.0
    QML_FILES ${qml_files}
)
