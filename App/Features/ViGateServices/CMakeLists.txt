set(qml_files
    components/PedestriansTable.qml
    components/SummaryCard.qml
    components/VehiclesTable.qml

    contents/ViGateContent.qml

    panels/ViGatePanel.qml
)

set(qml_singletons
    # store/ViGateStore.qml - replaced by C++ controller
)

set_source_files_properties(
    ${qml_singletons}
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE
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
    QML_FILES
        ${qml_files}
        ${qml_singletons}
    SOURCES ${cpp_sources}
    RESOURCE_PREFIX "/"
    RESOURCES ${icon_resources}
    SOURCES models/VehicleModel.h models/VehicleModel.cpp
    SOURCES models/PedestrianModel.h models/PedestrianModel.cpp
    SOURCES ViGateController.h ViGateController.cpp
)

target_link_libraries(app_features_vigateservices
    PRIVATE
        Qt6::Network
)
