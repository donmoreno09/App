set(qml_files
    TitleBar.qml
    components/SystemButton.qml
)

set(cpp_singletons
    WindowsNcController.h
    WindowsNcController.cpp
)

set(qml_singletons
    TitleBarController.qml
)

set_source_files_properties(
    ${qml_singletons}
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE
)

qt_add_qml_module(app_features_titlebar
    URI App.Features.TitleBar
    VERSION 1.0
    QML_FILES
        ${qml_files}
        ${qml_singletons}
    SOURCES ${cpp_singletons}
    RESOURCE_PREFIX "/"
)

target_link_libraries(app_features_titlebar
    PRIVATE
        Qt6::Quick
)
