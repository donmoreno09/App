.pragma library

Qt.include("qrc:/App/Features/MapModes/commands/ICommand.js")

/**
 * Command: Translate rectangle during creation mode
 *
 * This command is fired when a user drags the rectangle body during creation.
 * Works with CreateRectangleMode's topLeft/bottomRight properties.
 */
function TranslateRectangleCreationCommand(modeRef, oldTopLeft, oldBottomRight, newTopLeft, newBottomRight) {
    this.modeRef = modeRef;  // Reference to CreateRectangleMode
    this.oldTopLeft = oldTopLeft;
    this.oldBottomRight = oldBottomRight;
    this.newTopLeft = newTopLeft;
    this.newBottomRight = newBottomRight;
    this.timestamp = Date.now();
}

TranslateRectangleCreationCommand.prototype = Object.create(ICommand.prototype);
TranslateRectangleCreationCommand.prototype.constructor = TranslateRectangleCreationCommand;

TranslateRectangleCreationCommand.prototype.execute = function() {
    this._applyCorners(this.newTopLeft, this.newBottomRight);
};

TranslateRectangleCreationCommand.prototype.undo = function() {
    this._applyCorners(this.oldTopLeft, this.oldBottomRight);
};

TranslateRectangleCreationCommand.prototype.getDescription = function() {
    return qsTr("Move Rectangle (Creating)");
};

TranslateRectangleCreationCommand.prototype.canMergeWith = function(other) {
    return other instanceof TranslateRectangleCreationCommand &&
           (other.timestamp - this.timestamp) < 300;
};

TranslateRectangleCreationCommand.prototype.mergeWith = function(other) {
    this.newTopLeft = other.newTopLeft;
    this.newBottomRight = other.newBottomRight;
    this.timestamp = other.timestamp;
};

TranslateRectangleCreationCommand.prototype._applyCorners = function(topLeft, bottomRight) {
    if (!this.modeRef) {
        console.error("[TranslateRectangleCreationCommand] modeRef is null");
        return;
    }

    this.modeRef.applyNormalized(topLeft, bottomRight);
};
