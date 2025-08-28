set(qml_files
    BaseTheme.qml
    tokens/BorderTokens.qml
    tokens/ColorTokens.qml
    tokens/EffectTokens.qml
    tokens/ElevationTokens.qml
    tokens/IconTokens.qml
    tokens/LayoutTokens.qml
    tokens/OpacityTokens.qml
    tokens/RadiusTokens.qml
    tokens/SpacingTokens.qml
    tokens/TypographyTokens.qml
    variants/Fincantieri.qml
    variants/FincantieriLight.qml
)

set(qml_singletons
    Theme.qml
    Themes.qml
)

set(qml_test_files
    tst_Theme.qml
)

set_source_files_properties(
    ${qml_singletons}
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE
)

qt_add_qml_module(app_themes
    URI App.Themes
    VERSION 1.0
    QML_FILES
        ${qml_files}
        ${qml_singletons}
        ${qml_test_files}
)

# Qt Quick Test Configs
add_executable(tst_themes
    ${CMAKE_CURRENT_SOURCE_DIR}/tst_runner.cpp
)

target_link_libraries(tst_themes
    PRIVATE
        Qt6::QuickTest
        Qt6::Qml
)

# Scan this folder recursively for tst_*.qml (tests live alongside sources)
target_compile_definitions(tst_themes
    PRIVATE
        QUICK_TEST_SOURCE_DIR="${CMAKE_CURRENT_SOURCE_DIR}"
)

# Let the runner resolve the built App.Themes module at runtime
add_test(NAME tst_themes
    COMMAND tst_themes
        -import "${CMAKE_CURRENT_BINARY_DIR}"  # build dir of App/Themes module
        -platform offscreen                    # CI/headless-friendly
)
