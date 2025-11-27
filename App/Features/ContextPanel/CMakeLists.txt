set(qml_files
    ContextPanel.qml
    routes.js
)

set(qml_singletons
    ContextPanelController.qml
)

set_source_files_properties(
    ${qml_singletons}
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE
)

qt_add_qml_module(app_features_contextpanel
    URI App.Features.ContextPanel
    VERSION 1.0
    QML_FILES
        ${qml_files}
        ${qml_singletons}
    RESOURCE_PREFIX "/"
)

target_link_libraries(app_features_sidepanel
    PRIVATE
        Qt6::Quick
)
