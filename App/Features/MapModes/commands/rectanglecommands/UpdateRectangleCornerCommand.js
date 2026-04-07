.pragma library

Qt.include("qrc:/App/Features/MapModes/commands/ICommand.js")

function UpdateRectangleCornerCommand(alertZoneRef, oldTopLeft, oldBottomRight, newTopLeft, newBottomRight) {
    this.alertZoneRef = alertZoneRef;  // Reference to MapModeController.alertZone (QQmlPropertyMap)
    this.oldTopLeft = oldTopLeft;
    this.oldBottomRight = oldBottomRight;
    this.newTopLeft = newTopLeft;
    this.newBottomRight = newBottomRight;
    this.timestamp = Date.now();
}

UpdateRectangleCornerCommand.prototype = Object.create(ICommand.prototype);
UpdateRectangleCornerCommand.prototype.constructor = UpdateRectangleCornerCommand;

UpdateRectangleCornerCommand.prototype.execute = function() {
    this._applyCorners(this.newTopLeft, this.newBottomRight);
};

UpdateRectangleCornerCommand.prototype.undo = function() {
    this._applyCorners(this.oldTopLeft, this.oldBottomRight);
};

UpdateRectangleCornerCommand.prototype.canMergeWith = function(other) {
    return other instanceof UpdateRectangleCornerCommand &&
           other.alertZoneRef === this.alertZoneRef &&
           (other.timestamp - this.timestamp) < 300;
};

UpdateRectangleCornerCommand.prototype.mergeWith = function(other) {
    this.newTopLeft = other.newTopLeft;
    this.newBottomRight = other.newBottomRight;
    this.timestamp = other.timestamp;
};

UpdateRectangleCornerCommand.prototype._applyCorners = function(topLeft, bottomRight) {
    if (!this.alertZoneRef) {
        console.error("[UpdateRectangleCornerCommand] alertZoneRef is null");
        return;
    }

    this.alertZoneRef.topLeft = topLeft;
    this.alertZoneRef.bottomRight = bottomRight;
};
