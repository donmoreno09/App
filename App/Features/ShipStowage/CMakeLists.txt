set(qml_files
    components/WebViewItem.qml
    components/WebViewContainer.qml
)

set(qml_singletons
    ShipStowageController.qml
    WebEngineProfileManager.qml
)

set_source_files_properties(
    ${qml_singletons}
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE
)

qt_add_qml_module(app_features_shipstowage
    URI App.Features.ShipStowage
    VERSION 1.0
    QML_FILES
        ${qml_files}
        ${qml_singletons}
    RESOURCE_PREFIX "/"
)

target_link_libraries(app_features_shipstowage
    PRIVATE
        Qt6::Quick
        Qt6::WebEngineQuick
)
