set(qml_files
    components/DraggableResizableContainer.qml
    components/WebViewItem.qml
    components/WebViewContainer.qml

    panels/ShipStowagePanel.qml
)

qt_add_qml_module(app_features_shipstowage
    URI App.Features.ShipStowage
    VERSION 1.0
    QML_FILES ${qml_files}
    RESOURCE_PREFIX "/"
)

target_link_libraries(app_features_shipstowage
    PRIVATE
        Qt6::Quick
        Qt6::WebEngineQuick
)
