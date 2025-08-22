set(qml_files
    Button.qml
    DateTime.qml
)

set(icon_resources
    ../Playground/icons/clock.svg
)

qt_add_qml_module(app_components
    URI App.Components
    VERSION 1.0
    QML_FILES ${qml_files}
    RESOURCES ${icon_resources}
)
