set(qml_files
    SideRail.qml
    SideRailItem.qml
)

qt_add_qml_module(app_features_siderail
    URI App.Features.SideRail
    VERSION 1.0
    QML_FILES ${qml_files}
    RESOURCE_PREFIX "/"
)
