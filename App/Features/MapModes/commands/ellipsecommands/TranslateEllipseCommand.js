.pragma library

Qt.include("qrc:/App/Features/MapModes/commands/ICommand.js")

/**
 * Command: Translate entire ellipse in edit mode
 *
 * This command is fired when a user drags the ellipse body.
 * Uses the editable alert zone property map for updates.
 */
function TranslateEllipseCommand(alertZoneRef, oldCenter, oldRadiusA, oldRadiusB, newCenter, newRadiusA, newRadiusB) {
    this.alertZoneRef = alertZoneRef;  // Reference to MapModeController.alertZone (QQmlPropertyMap)
    this.oldCenter = oldCenter;
    this.oldRadiusA = oldRadiusA;
    this.oldRadiusB = oldRadiusB;
    this.newCenter = newCenter;
    this.newRadiusA = newRadiusA;
    this.newRadiusB = newRadiusB;
    this.timestamp = Date.now();
}

TranslateEllipseCommand.prototype = Object.create(ICommand.prototype);
TranslateEllipseCommand.prototype.constructor = TranslateEllipseCommand;

TranslateEllipseCommand.prototype.execute = function() {
    this._applyState(this.newCenter, this.newRadiusA, this.newRadiusB);
};

TranslateEllipseCommand.prototype.undo = function() {
    this._applyState(this.oldCenter, this.oldRadiusA, this.oldRadiusB);
};

TranslateEllipseCommand.prototype.getDescription = function() {
    return qsTr("Move Ellipse");
};

TranslateEllipseCommand.prototype.canMergeWith = function(other) {
    return other instanceof TranslateEllipseCommand &&
           other.alertZoneRef === this.alertZoneRef &&
           (other.timestamp - this.timestamp) < 300;
};

TranslateEllipseCommand.prototype.mergeWith = function(other) {
    this.newCenter = other.newCenter;
    this.newRadiusA = other.newRadiusA;
    this.newRadiusB = other.newRadiusB;
    this.timestamp = other.timestamp;
};

TranslateEllipseCommand.prototype._applyState = function(center, radiusA, radiusB) {
    if (!this.alertZoneRef) {
        console.error("[TranslateEllipseCommand] alertZoneRef is null");
        return;
    }

    console.log("[TranslateEllipseCommand] _applyState called:",
        "center:", center.latitude, center.longitude,
        "radiusA:", radiusA, "radiusB:", radiusB);

    this.alertZoneRef.coordinate = center;
    this.alertZoneRef.radiusA = radiusA;
    this.alertZoneRef.radiusB = radiusB;

    console.log("[TranslateEllipseCommand] After apply - alertZoneRef.coordinate:",
        this.alertZoneRef.coordinate.latitude, this.alertZoneRef.coordinate.longitude);
};
