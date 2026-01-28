set(qml_files
    Avatar.qml
    ButtonOld.qml
    ComboBox.qml
    DateTime.qml
    GlobalBackground.qml
    GlobalBackgroundConsumer.qml
    HorizontalDivider.qml
    HorizontalPadding.qml
    HorizontalSpacer.qml
    InputCoordinate.qml
    InputShield.qml
    Modal.qml
    OutlineRect.qml
    Overlay.qml
    Slider.qml
    SearchBar.qml
    Switcher.qml
    TextArea.qml
    Title.qml
    ToastNotification.qml
    VerticalDivider.qml
    VerticalPadding.qml
    VerticalSpacer.qml

    accordion/Accordion.qml
    accordion/AccordionStyle.qml

    button/ButtonStyle.qml
    button/Button.qml

    date-time-picker/DatePicker.qml
    date-time-picker/DatePickerActions.qml
    date-time-picker/DatePickerCalendarView.qml
    date-time-picker/DatePickerDay.qml
    date-time-picker/DatePickerHeader.qml
    date-time-picker/DatePickerMonthView.qml
    date-time-picker/DatePickerYearView.qml
    date-time-picker/DateTimePicker.qml
    date-time-picker/TimePicker.qml

    input/Input.qml
    input/InputStyle.qml

    wizard-page/WizardPage.qml
    wizard-page/constants/StepDefinitions.qml
    wizard-page/test-pages/MissionOverview.qml
    wizard-page/test-pages/OperationalArea.qml
    toggle/ToggleStyle.qml
    toggle/Toggle.qml

    floating-window/FloatingWindow.qml
    floating-window/windowRoutes.js

    forms/RectangleFormBase.qml
    forms/EllipseFormBase.qml
    forms/PolygonFormBase.qml
    forms/PointFormBase.qml

    shapes/EditableRectangle.qml
    shapes/EditableEllipse.qml
    shapes/EditablePolygon.qml
    shapes/EditablePoint.qml
)


set(qml_singletons
    accordion/AccordionStyles.qml
    button/ButtonStyles.qml
    input/InputStyles.qml
    toggle/ToggleStyles.qml
    floating-window/WindowRouter.qml
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
