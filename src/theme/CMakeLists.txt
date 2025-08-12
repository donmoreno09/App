set(qml_files
    BaseTheme.qml
    tokens/ColorTokens.qml
    tokens/TypographyTokens.qml
)

set(qml_singletons
    Theme.qml
)

set_source_files_properties(
    ${qml_singletons}
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE
)

qt_add_qml_module(app_themes
    URI App.Themes
    VERSION 1.0

    TARGET_PATH App/Themes
    OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/App/Themes"

    QML_FILES ${qml_files} ${qml_singletons}
)
