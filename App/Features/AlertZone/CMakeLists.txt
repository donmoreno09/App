set(qml_files
    AlertZonePanel.qml

    components/AlertZoneEllipseForm.qml
    components/AlertZonePolygonForm.qml
    components/AlertZoneRectangleForm.qml
    components/AreaButton.qml
    components/AreaForm.qml
    components/LayerSelection.qml
    components/Severity.qml
)

qt_add_qml_module(app_features_alertzone
    URI App.Features.AlertZone
    VERSION 1.0
    QML_FILES ${qml_files}
    RESOURCE_PREFIX "/"
)

target_link_libraries(app_features_alertzone
    PRIVATE
        Qt6::Quick
        Qt6::Location
        Qt6::Positioning
)
