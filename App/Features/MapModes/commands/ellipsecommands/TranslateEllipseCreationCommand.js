.pragma library

Qt.include("qrc:/App/Features/MapModes/commands/ICommand.js")

function TranslateEllipseCreationCommand(modeRef, oldCenter, oldRadiusA, oldRadiusB, newCenter, newRadiusA, newRadiusB) {
    this.modeRef = modeRef;
    this.oldCenter = oldCenter;
    this.oldRadiusA = oldRadiusA;
    this.oldRadiusB = oldRadiusB;
    this.newCenter = newCenter;
    this.newRadiusA = newRadiusA;
    this.newRadiusB = newRadiusB;
    this.timestamp = Date.now();
}

TranslateEllipseCreationCommand.prototype = Object.create(ICommand.prototype);
TranslateEllipseCreationCommand.prototype.constructor = TranslateEllipseCreationCommand;

TranslateEllipseCreationCommand.prototype.execute = function() {
    this._applyState(this.newCenter, this.newRadiusA, this.newRadiusB);
};

TranslateEllipseCreationCommand.prototype.undo = function() {
    this._applyState(this.oldCenter, this.oldRadiusA, this.oldRadiusB);
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

    if (!this.modeRef) {
        console.error("[TranslateEllipseCreationCommand] modeRef is null");
        return;
    }

    this.modeRef.setCenter(center.latitude, center.longitude);
    this.modeRef.setRadii(radiusA, radiusB);
};
