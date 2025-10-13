set(qml_files
    components/StatCard.qml

    contents/TrailersPredictionsContent.qml

    panels/TrailersPredictionsPanel.qml
)

set(cpp_sources
    TrailerPredictionController.cpp
    TrailerPredictionController.h
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
