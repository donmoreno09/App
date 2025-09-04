set(qml_files
    MapToolbar.qml
    components/MapToolbarContainer.qml
    components/MapToolbarItem.qml
)

qt_add_qml_module(app_features_maptoolbar
    URI App.Features.MapToolbar
    VERSION 1.0
    QML_FILES ${qml_files}
    RESOURCE_PREFIX "/"
)
