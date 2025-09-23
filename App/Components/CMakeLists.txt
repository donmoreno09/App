set(qml_files
    Avatar.qml
    Button.qml
    DateTime.qml
    GlobalBackground.qml
    GlobalBackgroundConsumer.qml
    HorizontalDivider.qml
    VerticalDivider.qml
    OutlineRect.qml
    SearchBar.qml
    Title.qml
    HorizontalPadding.qml
    VerticalPadding.qml
    HorizontalSpacer.qml
    VerticalSpacer.qml
    input/Input.qml
    input/InputStyle.qml
    InputCoordinate.qml
    TextArea.qml
    date-time-picker/DatePicker.qml
    date-time-picker/DatePickerHeader.qml
    date-time-picker/DatePickerYearView.qml
    date-time-picker/DatePickerMonthView.qml
    date-time-picker/DatePickerCalendarView.qml
    date-time-picker/DatePickerDay.qml
    date-time-picker/DatePickerActions.qml
    date-time-picker/TimePicker.qml
    date-time-picker/DateTimePicker.qml
    wizard-page/WizardPage.qml
    wizard-page/constants/StepDefinitions.qml
    wizard-page/test-pages/MissionOverview.qml
    wizard-page/test-pages/OperationalArea.qml
    toggle/ToggleStyle.qml
    toggle/Toggle.qml
)


set(qml_singletons
    input/InputStyles.qml
    toggle/ToggleStyles.qml
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
    RESOURCE_PREFIX "/"
    RESOURCES ${icon_resources}
)
