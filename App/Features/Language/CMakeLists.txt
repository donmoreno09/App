qt_add_library(app_features_language STATIC)

set(qml_files
    LanguagePanel.qml
    components/LanguageItem.qml
)

set(cpp_files
    LanguageController.h
    LanguageController.cpp
    LanguageEnum.h
    LanguageEnum.cpp
    LanguageLogger.h
    TranslationManager.h
    TranslationManager.cpp
)

qt_add_qml_module(app_features_language
    URI App.Features.Language
    VERSION 1.0
    QML_FILES ${qml_files}
    SOURCES ${cpp_files}
    RESOURCE_PREFIX "/"
)

target_include_directories(app_features_language
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}
)

target_link_libraries(app_features_language
    PRIVATE
        Qt6::Gui
        Qt6::Qml
        Qt6::Quick

        app_logger
        app_loggerplugin
)
