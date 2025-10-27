set(qml_files
    components/SummaryTable.qml
    components/TransitsTable.qml

    contents/ViGateContent.qml

    panels/ViGatePanel.qml
)

set(cpp_sources
    ViGateController.cpp
    ViGateController.h
    services/ViGateService.cpp
    services/ViGateService.h
    models/TransitModel.cpp
    models/TransitModel.h
)

qt_add_qml_module(app_features_vigateservices
    URI App.Features.ViGateServices
    VERSION 1.0
    QML_FILES ${qml_files}
    SOURCES ${cpp_sources}
    RESOURCE_PREFIX "/"
    RESOURCES ${icon_resources}
)
