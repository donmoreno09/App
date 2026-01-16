.pragma library

Qt.include("qrc:/App/Features/MapModes/commands/ICommand.js")

/**
 * Command: Update rectangle corners (corner handle drag)
 *
 * This command is fired when a user drags a corner handle in edit mode.
 * Stores both corners since dragging one corner can affect normalization.
 * Uses the editable alert zone property map for updates.
 */
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

UpdateRectangleCornerCommand.prototype.getDescription = function() {
    return qsTr("Resize Rectangle");
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
