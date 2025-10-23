set(qml_files
    modes/BaseMode.qml
    modes/InteractionMode.qml

    modes/point/PointMode.qml
    modes/point/CreatePointMode.qml
    modes/point/EditPointMode.qml
)

set(qml_singletons
    MapModeController.qml
    MapModeRegistry.qml
)

set_source_files_properties(
    ${qml_singletons}
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE
)

qt_add_qml_module(app_features_mapmodes
    URI App.Features.MapModes
    VERSION 1.0
    QML_FILES
        ${qml_files}
        ${qml_singletons}
    RESOURCE_PREFIX "/"
)
