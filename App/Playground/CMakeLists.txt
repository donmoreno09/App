set(qml_files
    ButtonGroupTest.qml
    DateTimePickerPanel.qml
    IconButtonsTest.qml
    DateTimeTest.qml
    WizardPageTest.qml
    FontTest.qml
    TogglePanel.qml
)

qt_add_qml_module(app_playground
    URI App.Playground
    VERSION 1.0
    QML_FILES ${qml_files}
    RESOURCE_PREFIX "/"
)

