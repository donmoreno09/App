.pragma library

Qt.include("qrc:/App/Features/MapModes/commands/ICommand.js")

/**
 * Command: Set point coordinate during creation mode
 *
 * This command is fired when a user clicks or drags the point during creation.
 * Works with CreatePointMode's coord property.
 */
function SetPointCoordinateCommand(modeRef, oldCoord, newCoord) {
    this.modeRef = modeRef;  // Reference to CreatePointMode
    this.oldCoord = oldCoord;
    this.newCoord = newCoord;
    this.timestamp = Date.now();

    console.log("[SetPointCoordinateCommand] Constructor called:");
    console.log("  oldCoord:", oldCoord ? (oldCoord.latitude + ", " + oldCoord.longitude) : "null/invalid");
    console.log("  newCoord:", newCoord ? (newCoord.latitude + ", " + newCoord.longitude) : "null/invalid");
}

SetPointCoordinateCommand.prototype = Object.create(ICommand.prototype);
SetPointCoordinateCommand.prototype.constructor = SetPointCoordinateCommand;

SetPointCoordinateCommand.prototype.execute = function() {
    console.log("[SetPointCoordinateCommand] execute() called");
    this._applyState(this.newCoord);
};

SetPointCoordinateCommand.prototype.undo = function() {
    console.log("[SetPointCoordinateCommand] undo() called");
    console.log("  Restoring oldCoord:", this.oldCoord ? (this.oldCoord.latitude + ", " + this.oldCoord.longitude) : "null/invalid");
    this._applyState(this.oldCoord);
};

SetPointCoordinateCommand.prototype.getDescription = function() {
    return qsTr("Set Point (Creating)");
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
    console.log("[SetPointCoordinateCommand] _applyState called:");
    console.log("  coord:", coord ? (coord.latitude + ", " + coord.longitude) : "null/invalid");
    console.log("  modeRef:", this.modeRef ? "valid" : "null");

    if (!this.modeRef) {
        console.error("[SetPointCoordinateCommand] modeRef is null");
        return;
    }

    console.log("  Before - modeRef.coord:", this.modeRef.coord.latitude, this.modeRef.coord.longitude);

    this.modeRef.setCoordinate(coord.latitude, coord.longitude);

    console.log("  After - modeRef.coord:", this.modeRef.coord.latitude, this.modeRef.coord.longitude);
};
