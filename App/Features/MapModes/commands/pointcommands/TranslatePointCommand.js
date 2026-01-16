.pragma library

Qt.include("qrc:/App/Features/MapModes/commands/ICommand.js")

/**
 * Command: Translate point in edit mode
 *
 * This command is fired when a user drags an existing POI point.
 * Uses the editable POI property map for updates.
 */
function TranslatePointCommand(poiRef, oldCoord, newCoord) {
    this.poiRef = poiRef;  // Reference to MapModeController.poi (QQmlPropertyMap)
    this.oldCoord = oldCoord;
    this.newCoord = newCoord;
    this.timestamp = Date.now();

    console.log("[TranslatePointCommand] Constructor called:");
    console.log("  oldCoord:", oldCoord ? (oldCoord.latitude + ", " + oldCoord.longitude) : "null");
    console.log("  newCoord:", newCoord ? (newCoord.latitude + ", " + newCoord.longitude) : "null");
}

TranslatePointCommand.prototype = Object.create(ICommand.prototype);
TranslatePointCommand.prototype.constructor = TranslatePointCommand;

TranslatePointCommand.prototype.execute = function() {
    console.log("[TranslatePointCommand] execute() called");
    this._applyState(this.newCoord);
};

TranslatePointCommand.prototype.undo = function() {
    console.log("[TranslatePointCommand] undo() called");
    this._applyState(this.oldCoord);
};

TranslatePointCommand.prototype.getDescription = function() {
    return qsTr("Move Point");
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

    console.log("[TranslatePointCommand] _applyState called:",
        "coord:", coord.latitude, coord.longitude);

    this.poiRef.coordinate = coord;

    console.log("[TranslatePointCommand] After apply - poiRef.coordinate:",
        this.poiRef.coordinate.latitude, this.poiRef.coordinate.longitude);
};
