.pragma library

// Include the base interface first so it's available to all commands
Qt.include("ICommand.js")

// Re-export all rectangle commands from individual modules
Qt.include("rectanglecommands/UpdateRectangleCornerCommand.js")
Qt.include("rectanglecommands/TranslateRectangleCommand.js")
Qt.include("rectanglecommands/TranslateRectangleCreationCommand.js")
