set(qml_files
    LanguagePanel.qml
    components/LanguageItem.qml
)

set(cpp_files
    LanguageController.h
    LanguageController.cpp
    LanguageEnum.h
    LanguageEnum.cpp
    TranslationManager.h
    TranslationManager.cpp
)

set(qml_singletons
    TranslationHelper.qml
)

set_source_files_properties(
    ${qml_singletons}
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE
)

qt_add_qml_module(app_features_language
    URI App.Features.Language
    VERSION 1.0
    QML_FILES
        ${qml_files}
        ${qml_singletons}
    SOURCES ${cpp_files}
    RESOURCE_PREFIX "/"
)

target_link_libraries(app_features_language
    PRIVATE
        Qt6::Gui
        Qt6::Qml
        Qt6::Quick
)
