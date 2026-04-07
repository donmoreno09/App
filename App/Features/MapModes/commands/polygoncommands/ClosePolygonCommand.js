.pragma library

Qt.include("qrc:/App/Features/MapModes/commands/ICommand.js")

function ClosePolygonCommand(modeRef) {
    this.modeRef = modeRef;
    this.wasClosed = modeRef.closed;
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

ClosePolygonCommand.prototype.canMergeWith = function(other) {
    return false;
};

ClosePolygonCommand.prototype.mergeWith = function(other) {
    // Not applicable
};
