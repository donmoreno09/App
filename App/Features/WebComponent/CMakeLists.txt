set(qml_files
    components/DraggableWebContainer.qml
    components/WebViewFrame.qml
    panels/WebComponentPanel.qml
)

qt_add_qml_module(app_features_webcomponent
    URI App.Features.WebComponent
    VERSION 1.0
    QML_FILES ${qml_files}
    RESOURCE_PREFIX "/"
)

target_link_libraries(app_features_webcomponent
    PRIVATE
        Qt6::Quick
        Qt6::WebEngineQuick
)
