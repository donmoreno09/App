set(qml_files
    components/PedestriansTable.qml
    components/SummaryTable.qml
    components/VehiclesTable.qml

    contents/ViGateContent.qml

    panels/ViGatePanel.qml
)

set(cpp_sources
    ViGateController.cpp
    ViGateController.h
    services/ViGateService.cpp
    services/ViGateService.h
    models/VehicleModel.cpp
    models/VehicleModel.h
    models/PedestrianModel.cpp
    models/PedestrianModel.h
)

qt_add_qml_module(app_features_vigateservices
    URI App.Features.ViGateServices
    VERSION 1.0
    QML_FILES ${qml_files}
    SOURCES ${cpp_sources}
    RESOURCE_PREFIX "/"
    RESOURCES ${icon_resources}
)
