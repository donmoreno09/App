.pragma library

Qt.include("qrc:/App/Features/MapModes/commands/ICommand.js")

function UpdateEllipseRadiusCommand(alertZoneRef, oldCenter, oldRadiusA, oldRadiusB, newCenter, newRadiusA, newRadiusB) {
    this.alertZoneRef = alertZoneRef;
    this.oldCenter = oldCenter;
    this.oldRadiusA = oldRadiusA;
    this.oldRadiusB = oldRadiusB;
    this.newCenter = newCenter;
    this.newRadiusA = newRadiusA;
    this.newRadiusB = newRadiusB;
    this.timestamp = Date.now();
}

UpdateEllipseRadiusCommand.prototype = Object.create(ICommand.prototype);
UpdateEllipseRadiusCommand.prototype.constructor = UpdateEllipseRadiusCommand;

UpdateEllipseRadiusCommand.prototype.execute = function() {
    this._applyState(this.newCenter, this.newRadiusA, this.newRadiusB);
};

UpdateEllipseRadiusCommand.prototype.undo = function() {
    this._applyState(this.oldCenter, this.oldRadiusA, this.oldRadiusB);
};

UpdateEllipseRadiusCommand.prototype.canMergeWith = function(other) {
    return other instanceof UpdateEllipseRadiusCommand &&
           other.alertZoneRef === this.alertZoneRef &&
           (other.timestamp - this.timestamp) < 300;
};

UpdateEllipseRadiusCommand.prototype.mergeWith = function(other) {
    this.newCenter = other.newCenter;
    this.newRadiusA = other.newRadiusA;
    this.newRadiusB = other.newRadiusB;
    this.timestamp = other.timestamp;
};

UpdateEllipseRadiusCommand.prototype._applyState = function(center, radiusA, radiusB) {
    if (!this.alertZoneRef) {
        console.error("[UpdateEllipseRadiusCommand] alertZoneRef is null");
        return;
    }

    this.alertZoneRef.coordinate = center;
    this.alertZoneRef.radiusA = radiusA;
    this.alertZoneRef.radiusB = radiusB;
};
