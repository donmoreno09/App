set(qml_files
    Button.qml
    DateTime.qml
    GlobalBackground.qml
    GlobalBackgroundConsumer.qml
    HorizontalPadding.qml
    VerticalPadding.qml
    HorizontalSpacer.qml
    VerticalSpacer.qml
    wizard-page/WizardPage.qml
    wizard-page/constants/StepDefinitions.qml
    wizard-page/test-pages/MissionOverview.qml
    wizard-page/test-pages/OperationalArea.qml
)

qt_add_qml_module(app_components
    URI App.Components
    VERSION 1.0
    QML_FILES ${qml_files}
    RESOURCES ${icon_resources}
)
