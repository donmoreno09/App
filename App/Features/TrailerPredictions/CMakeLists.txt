qt_add_library(app_features_trailerpredictions STATIC)

set(qml_files
    components/StatCard.qml

    contents/TrailersPredictionsContent.qml

    panels/TrailersPredictionsPanel.qml
)

set(cpp_sources
    TrailerPredictionController.cpp
    TrailerPredictionController.h
    TrailerPredictionsLogger.h
    services/TrailerPredictionService.cpp
    services/TrailerPredictionService.h
)

qt_add_qml_module(app_features_trailerpredictions
    URI App.Features.TrailerPredictions
    VERSION 1.0
    QML_FILES ${qml_files}
    SOURCES ${cpp_sources}
    RESOURCE_PREFIX "/"
    RESOURCES ${icon_resources}
)

target_link_libraries(app_features_trailerpredictions
    PRIVATE
        Qt6::Core
        Qt6::Gui
        Qt6::Qml
        Qt6::Quick

        app_logger
        app_loggerplugin
)
