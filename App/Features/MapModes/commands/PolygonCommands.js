.pragma library

// Include the base interface first so it's available to all commands
Qt.include("ICommand.js")

Qt.include("polygoncommands/AddPolygonVertexCommand.js")
Qt.include("polygoncommands/ClosePolygonCommand.js")
Qt.include("polygoncommands/TranslatePolygonCommand.js")
Qt.include("polygoncommands/TranslatePolygonCreationCommand.js")
Qt.include("polygoncommands/UpdatePolygonVertexCommand.js")
