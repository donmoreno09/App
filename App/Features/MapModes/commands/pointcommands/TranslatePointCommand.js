.pragma library

Qt.include("qrc:/App/Features/MapModes/commands/ICommand.js")

function TranslatePointCommand(poiRef, oldCoord, newCoord) {
    this.poiRef = poiRef;
    this.oldCoord = oldCoord;
    this.newCoord = newCoord;
    this.timestamp = Date.now();
}

TranslatePointCommand.prototype = Object.create(ICommand.prototype);
TranslatePointCommand.prototype.constructor = TranslatePointCommand;

TranslatePointCommand.prototype.execute = function() {
    this._applyState(this.newCoord);
};

TranslatePointCommand.prototype.undo = function() {
    this._applyState(this.oldCoord);
};

TranslatePointCommand.prototype.canMergeWith = function(other) {
    return other instanceof TranslatePointCommand &&
           other.poiRef === this.poiRef &&
           Math.abs(other.timestamp - this.timestamp) < 300;
};

TranslatePointCommand.prototype.mergeWith = function(other) {
    this.newCoord = other.newCoord;
    this.timestamp = other.timestamp;
};

TranslatePointCommand.prototype._applyState = function(coord) {
    if (!this.poiRef) {
        console.error("[TranslatePointCommand] poiRef is null");
        return;
    }

    this.poiRef.coordinate = coord;
};
