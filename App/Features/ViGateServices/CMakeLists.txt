set(qml_files
    components/SummaryTable.qml
    components/TableHeader.qml
    components/TransitRow.qml
    components/TransitsTable.qml

    contents/ViGateContent.qml

    panels/ViGatePanel.qml

    windows/TransitDetailsWindow.qml
)

set(cpp_sources
    ViGateController.cpp
    ViGateController.h

    entities/TransitEntry.h
    entities/TransitInfo.h
    entities/TransitPermission.h

    models/TransitModel.cpp
    models/TransitModel.h
    models/TransitProxyModel.cpp
    models/TransitProxyModel.h

    services/ViGateService.cpp
    services/ViGateService.h
)

set(qml_singletons
    components/ColumnConfig.qml
)

set_source_files_properties(
    ${qml_singletons}
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE
)


qt_add_qml_module(app_features_vigateservices
    URI App.Features.ViGateServices
    VERSION 1.0
    QML_FILES
        ${qml_files}
        ${qml_singletons}
    SOURCES ${cpp_sources}
    RESOURCE_PREFIX "/"
    RESOURCES ${icon_resources}
)

target_link_libraries(app_features_vigateservices
    PRIVATE
        Qt6::Concurrent
        Qt6::Core
        Qt6::Network
)
