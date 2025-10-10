set(qml_files
    TrackPanel.qml
)

set(qml_singletons
    SelectedTrackState.qml
)

set_source_files_properties(
    ${qml_singletons}
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE
)

qt_add_qml_module(app_features_trackpanel
    URI App.Features.TrackPanel
    VERSION 1.0
    QML_FILES
        ${qml_files}
        ${qml_singletons}
    RESOURCE_PREFIX "/"
)
