set(qml_files
    BaseTheme.qml
    tokens/BorderTokens.qml
    tokens/ColorTokens.qml
    tokens/ElevationTokens.qml
    tokens/RadiusTokens.qml
    tokens/SpacingTokens.qml
    tokens/TypographyTokens.qml
    variants/Fincantieri.qml
    variants/FincantieriLight.qml
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
    QML_FILES ${qml_files} ${qml_singletons}
)
