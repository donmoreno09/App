set(qml_files
    Button.qml
    DateTime.qml
    GlobalBackground.qml
    GlobalBackgroundConsumer.qml
    HorizontalPadding.qml
    VerticalPadding.qml
    HorizontalSpacer.qml
    VerticalSpacer.qml
    title/Title.qml
    wizard-page/WizardPage.qml
    wizard-page/constants/StepDefinitions.qml
    wizard-page/test-pages/MissionOverview.qml
    wizard-page/test-pages/OperationalArea.qml
)

set(qml_singletons
    title/TitleController.qml
)

set_source_files_properties(
    ${qml_singletons}
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE
)

qt_add_qml_module(app_components
    URI App.Components
    VERSION 1.0
    QML_FILES
        ${qml_files}
        ${qml_singletons}
    RESOURCES ${icon_resources}
)
