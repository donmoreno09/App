.pragma library

Qt.include("qrc:/App/Features/MapModes/commands/ICommand.js")

/**
 * Command: Translate polygon during creation mode
 */
function TranslatePolygonCreationCommand(modeRef, oldPath, newPath) {
    this.modeRef = modeRef;
    this.oldPath = oldPath;
    this.newPath = newPath;
    this.timestamp = Date.now();
}

TranslatePolygonCreationCommand.prototype = Object.create(ICommand.prototype);
TranslatePolygonCreationCommand.prototype.constructor = TranslatePolygonCreationCommand;

TranslatePolygonCreationCommand.prototype.execute = function() {
    this._applyPath(this.newPath);
};

TranslatePolygonCreationCommand.prototype.undo = function() {
    this._applyPath(this.oldPath);
};

TranslatePolygonCreationCommand.prototype.getDescription = function() {
    return qsTr("Move Polygon (Creating)");
};

TranslatePolygonCreationCommand.prototype.canMergeWith = function(other) {
    return other instanceof TranslatePolygonCreationCommand &&
           (other.timestamp - this.timestamp) < 300;
};

TranslatePolygonCreationCommand.prototype.mergeWith = function(other) {
    this.newPath = other.newPath;
    this.timestamp = other.timestamp;
};

TranslatePolygonCreationCommand.prototype._applyPath = function(path) {
    const model = this.modeRef.coordinatesModel;
    for (let i = 0; i < path.length; i++) {
        if (i < model.count) {
            model.set(i, path[i]);
        } else {
            model.append(path[i]);
        }
    }
    this.modeRef._syncPathFromModel();
};
