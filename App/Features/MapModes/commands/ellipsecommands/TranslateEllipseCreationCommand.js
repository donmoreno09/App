.pragma library

Qt.include("qrc:/App/Features/MapModes/commands/ICommand.js")

/**
 * Command: Translate ellipse during creation mode
 *
 * This command is fired when a user drags the ellipse body during creation.
 * Works with CreateEllipseMode's coord, radiusA, radiusB properties.
 */
function TranslateEllipseCreationCommand(modeRef, oldCenter, oldRadiusA, oldRadiusB, newCenter, newRadiusA, newRadiusB) {
    this.modeRef = modeRef;  // Reference to CreateEllipseMode
    this.oldCenter = oldCenter;
    this.oldRadiusA = oldRadiusA;
    this.oldRadiusB = oldRadiusB;
    this.newCenter = newCenter;
    this.newRadiusA = newRadiusA;
    this.newRadiusB = newRadiusB;
    this.timestamp = Date.now();

    console.log("[TranslateEllipseCreationCommand] Constructor called:");
    console.log("  oldCenter:", oldCenter ? (oldCenter.latitude + ", " + oldCenter.longitude) : "null");
    console.log("  oldRadiusA:", oldRadiusA, "oldRadiusB:", oldRadiusB);
    console.log("  newCenter:", newCenter ? (newCenter.latitude + ", " + newCenter.longitude) : "null");
    console.log("  newRadiusA:", newRadiusA, "newRadiusB:", newRadiusB);
}

TranslateEllipseCreationCommand.prototype = Object.create(ICommand.prototype);
TranslateEllipseCreationCommand.prototype.constructor = TranslateEllipseCreationCommand;

TranslateEllipseCreationCommand.prototype.execute = function() {
    console.log("[TranslateEllipseCreationCommand] execute() called");
    this._applyState(this.newCenter, this.newRadiusA, this.newRadiusB);
};

TranslateEllipseCreationCommand.prototype.undo = function() {
    console.log("[TranslateEllipseCreationCommand] undo() called");
    console.log("  Stored oldCenter:", this.oldCenter ? (this.oldCenter.latitude + ", " + this.oldCenter.longitude) : "null");
    console.log("  Stored oldRadiusA:", this.oldRadiusA, "oldRadiusB:", this.oldRadiusB);
    this._applyState(this.oldCenter, this.oldRadiusA, this.oldRadiusB);
};

TranslateEllipseCreationCommand.prototype.getDescription = function() {
    return qsTr("Move Ellipse (Creating)");
};

TranslateEllipseCreationCommand.prototype.canMergeWith = function(other) {
    return other instanceof TranslateEllipseCreationCommand &&
           (other.timestamp - this.timestamp) < 300;
};

TranslateEllipseCreationCommand.prototype.mergeWith = function(other) {
    this.newCenter = other.newCenter;
    this.newRadiusA = other.newRadiusA;
    this.newRadiusB = other.newRadiusB;
    this.timestamp = other.timestamp;
};

TranslateEllipseCreationCommand.prototype._applyState = function(center, radiusA, radiusB) {
    console.log("[TranslateEllipseCreationCommand] _applyState called:");
    console.log("  center:", center ? (center.latitude + ", " + center.longitude) : "null");
    console.log("  radiusA:", radiusA, "radiusB:", radiusB);
    console.log("  modeRef:", this.modeRef ? "valid" : "null");

    if (!this.modeRef) {
        console.error("[TranslateEllipseCreationCommand] modeRef is null");
        return;
    }

    console.log("  Before - modeRef.coord:", this.modeRef.coord.latitude, this.modeRef.coord.longitude);
    console.log("  Before - modeRef.radiusA:", this.modeRef.radiusA, "radiusB:", this.modeRef.radiusB);

    this.modeRef.setCenter(center.latitude, center.longitude);
    this.modeRef.setRadii(radiusA, radiusB);

    console.log("  After - modeRef.coord:", this.modeRef.coord.latitude, this.modeRef.coord.longitude);
    console.log("  After - modeRef.radiusA:", this.modeRef.radiusA, "radiusB:", this.modeRef.radiusB);
};
