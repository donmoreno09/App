set(qml_files
    IconButtonsTest.qml
)

set(icon_resources
    icons/map.svg
    icons/home.svg
    icons/send.svg
    icons/plus.svg
    icons/minus.svg
    icons/clipboard.svg
)

qt_add_qml_module(app_playground
    URI App.Playground
    VERSION 1.0
    QML_FILES ${qml_files}
    RESOURCES ${icon_resources}
)
