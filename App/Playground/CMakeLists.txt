set(qml_files
    ButtonGroupTest.qml
    ComboBoxPanel.qml
    DateTimePickerPanel.qml
    IconButtonsTest.qml
    DateTimeTest.qml
    WizardPageTest.qml
    FontTest.qml
    TextAreaPanel.qml
    TogglePanel.qml
    OverlayPanel.qml
    SwitcherPanel.qml
    SliderPanel.qml
    ModalPanel.qml
    ButtonPanel.qml
)

qt_add_qml_module(app_playground
    URI App.Playground
    VERSION 1.0
    QML_FILES ${qml_files}
    RESOURCE_PREFIX "/"
)
