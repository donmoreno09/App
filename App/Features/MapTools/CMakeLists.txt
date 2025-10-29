set(qml_files
    components/InputHandler.qml
)

set(cpp_files
    MapToolController.h
    MapToolController.cpp
    MapToolRegistry.h
    MapToolRegistry.cpp

    tools/BaseTool.h
    tools/EllipseTool.h
    tools/EllipseTool.cpp
    tools/PointTool.h
    tools/PointTool.cpp
    tools/RectangleTool.h
    tools/RectangleTool.cpp
)

qt_add_qml_module(app_features_maptools
    URI App.Features.MapTools
    VERSION 1.0
    QML_FILES ${qml_files}
    SOURCES ${cpp_files}
    RESOURCE_PREFIX "/"
)

target_link_libraries(app_features_maptools
    PRIVATE
        Qt6::Quick
        Qt6::Location
        Qt6::Positioning
)
