set(qml_files
    Avatar.qml
    Button.qml
    ButtonGroup.qml
    DateTime.qml
    GlobalBackground.qml
    GlobalBackgroundConsumer.qml
    HorizontalPadding.qml
    VerticalPadding.qml
    HorizontalSpacer.qml
    VerticalSpacer.qml
    HorizontalDivider.qml
    Title.qml
    VerticalDivider.qml
    wizard-page/WizardPage.qml
    wizard-page/constants/StepDefinitions.qml
    wizard-page/test-pages/MissionOverview.qml
    wizard-page/test-pages/OperationalArea.qml
)

qt_add_qml_module(app_components
    URI App.Components
    VERSION 1.0
    QML_FILES ${qml_files}
    RESOURCE_PREFIX "/"
    RESOURCES ${icon_resources}
    QML_FILES
)
