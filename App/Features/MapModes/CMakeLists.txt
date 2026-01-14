set(qml_files
    modes/BaseMode.qml
    modes/InteractionMode.qml

    modes/point/PointMode.qml
    modes/point/CreatePointMode.qml
    modes/point/EditPointMode.qml

    modes/rectangle/RectangleMode.qml
    modes/rectangle/CreateRectangleMode.qml
    modes/rectangle/EditRectangleMode.qml
    modes/rectangle/RectangleGeometry.js

    modes/ellipse/EllipseMode.qml
    modes/ellipse/CreateEllipseMode.qml
    modes/ellipse/EditEllipseMode.qml
    modes/ellipse/EllipseGeometry.js

    modes/polygon/PolygonMode.qml
    modes/polygon/CreatePolygonMode.qml
    modes/polygon/EditPolygonMode.qml
    modes/polygon/PolygonGeometry.js

    commands/ICommand.js
    commands/PolygonCommands.js
)

set(qml_singletons
    MapModeController.qml
    MapModeRegistry.qml
    commands/CommandManager.qml
)

set_source_files_properties(
    ${qml_singletons}
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE
)

qt_add_qml_module(app_features_mapmodes
    URI App.Features.MapModes
    VERSION 1.0
    QML_FILES
        ${qml_files}
        ${qml_singletons}
    RESOURCE_PREFIX "/"
)

