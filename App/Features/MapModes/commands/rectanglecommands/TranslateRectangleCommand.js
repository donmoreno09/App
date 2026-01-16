.pragma library

Qt.include("qrc:/App/Features/MapModes/commands/ICommand.js")

/**
 * Command: Translate entire rectangle in edit mode
 *
 * This command is fired when a user drags the rectangle body.
 * Uses the editable alert zone property map for updates.
 */
function TranslateRectangleCommand(alertZoneRef, oldTopLeft, oldBottomRight, newTopLeft, newBottomRight) {
    this.alertZoneRef = alertZoneRef;  // Reference to MapModeController.alertZone (QQmlPropertyMap)
    this.oldTopLeft = oldTopLeft;
    this.oldBottomRight = oldBottomRight;
    this.newTopLeft = newTopLeft;
    this.newBottomRight = newBottomRight;
    this.timestamp = Date.now();
}

TranslateRectangleCommand.prototype = Object.create(ICommand.prototype);
TranslateRectangleCommand.prototype.constructor = TranslateRectangleCommand;

TranslateRectangleCommand.prototype.execute = function() {
    this._applyCorners(this.newTopLeft, this.newBottomRight);
};

TranslateRectangleCommand.prototype.undo = function() {
    this._applyCorners(this.oldTopLeft, this.oldBottomRight);
};

TranslateRectangleCommand.prototype.getDescription = function() {
    return qsTr("Move Rectangle");
};

TranslateRectangleCommand.prototype.canMergeWith = function(other) {
    return other instanceof TranslateRectangleCommand &&
           other.alertZoneRef === this.alertZoneRef &&
           (other.timestamp - this.timestamp) < 300;
};

TranslateRectangleCommand.prototype.mergeWith = function(other) {
    this.newTopLeft = other.newTopLeft;
    this.newBottomRight = other.newBottomRight;
    this.timestamp = other.timestamp;
};

TranslateRectangleCommand.prototype._applyCorners = function(topLeft, bottomRight) {
    if (!this.alertZoneRef) {
        console.error("[TranslateRectangleCommand] alertZoneRef is null");
        return;
    }

    this.alertZoneRef.topLeft = topLeft;
    this.alertZoneRef.bottomRight = bottomRight;
};
