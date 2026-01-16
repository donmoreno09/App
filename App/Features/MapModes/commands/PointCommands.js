.pragma library

// Include the base interface first so it's available to all commands
Qt.include("ICommand.js")

// Re-export all point commands from individual modules
Qt.include("pointcommands/SetPointCoordinateCommand.js")
Qt.include("pointcommands/TranslatePointCommand.js")
