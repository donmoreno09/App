.pragma library

Qt.include("qrc:/App/Features/MapModes/commands/ICommand.js")

/**
 * Command: Close polygon during creation
 *
 * This command is fired when user double-clicks or clicks first vertex.
 */
function ClosePolygonCommand(modeRef) {
    this.modeRef = modeRef;
    this.wasClosed = modeRef.closed; // Store previous state
}

ClosePolygonCommand.prototype = Object.create(ICommand.prototype);
ClosePolygonCommand.prototype.constructor = ClosePolygonCommand;

ClosePolygonCommand.prototype.execute = function() {
    this.modeRef._tryClose();
};

ClosePolygonCommand.prototype.undo = function() {
    this.modeRef.closed = this.wasClosed;
    this.modeRef.coordinatesChanged();
};

ClosePolygonCommand.prototype.getDescription = function() {
    return qsTr("Close Polygon");
};

ClosePolygonCommand.prototype.canMergeWith = function(other) {
    return false;
};

ClosePolygonCommand.prototype.mergeWith = function(other) {
    // Not applicable
};
