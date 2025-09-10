set(qml_files
    BasePanel.qml
    NotFoundPanel.qml
    PanelTemplate.qml
    SidePanel.qml
    routes.js
)

set(qml_singletons
    PanelRouter.qml
    SidePanelController.qml
)

find_package(Qt6 REQUIRED COMPONENTS Quick)

set_source_files_properties(
    ${qml_singletons}
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE
)

qt_add_qml_module(app_features_sidepanel
    URI App.Features.SidePanel
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
