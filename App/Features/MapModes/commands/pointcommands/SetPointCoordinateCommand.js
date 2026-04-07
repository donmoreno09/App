.pragma library

Qt.include("qrc:/App/Features/MapModes/commands/ICommand.js")

function SetPointCoordinateCommand(modeRef, oldCoord, newCoord) {
    this.modeRef = modeRef;
    this.oldCoord = oldCoord;
    this.newCoord = newCoord;
    this.timestamp = Date.now();
}

SetPointCoordinateCommand.prototype = Object.create(ICommand.prototype);
SetPointCoordinateCommand.prototype.constructor = SetPointCoordinateCommand;

SetPointCoordinateCommand.prototype.execute = function() {
    this._applyState(this.newCoord);
};

SetPointCoordinateCommand.prototype.undo = function() {
    this._applyState(this.oldCoord);
};

SetPointCoordinateCommand.prototype.canMergeWith = function(other) {
    return other instanceof SetPointCoordinateCommand &&
           other.modeRef === this.modeRef &&
           Math.abs(other.timestamp - this.timestamp) < 300;
};

SetPointCoordinateCommand.prototype.mergeWith = function(other) {
    this.newCoord = other.newCoord;
    this.timestamp = other.timestamp;
};

SetPointCoordinateCommand.prototype._applyState = function(coord) {
    if (!this.modeRef) {
        console.error("[SetPointCoordinateCommand] modeRef is null");
        return;
    }

    this.modeRef.setCoordinate(coord.latitude, coord.longitude);
};
