set(qml_files
    BasePanel.qml
    NotFoundPanel.qml
    PanelController.qml
    PanelRouter.qml
    PanelTemplate.qml
)

qt_add_qml_module(app_features_panels
    URI App.Features.Panels
    VERSION 1.0
    QML_FILES ${qml_files}
    RESOURCE_PREFIX "/"
)

target_link_libraries(app_features_panels PRIVATE Qt6::Quick)
