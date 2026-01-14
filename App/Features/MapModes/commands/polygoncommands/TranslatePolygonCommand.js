.pragma library

Qt.include("qrc:/App/Features/MapModes/commands/ICommand.js")

/**
 * Command: Translate entire polygon in edit mode
 *
 * This command is fired when a user drags the polygon body.
 */
function TranslatePolygonCommand(modelRef, entityId, oldPath, newPath) {
    this.modelRef = modelRef;
    this.entityId = entityId;
    this.oldPath = oldPath; // Array of {latitude, longitude}
    this.newPath = newPath; // Array of {latitude, longitude}
    this.timestamp = Date.now();
}

TranslatePolygonCommand.prototype = Object.create(ICommand.prototype);
TranslatePolygonCommand.prototype.constructor = TranslatePolygonCommand;

TranslatePolygonCommand.prototype.execute = function() {
    this._applyPath(this.newPath);
};

TranslatePolygonCommand.prototype.undo = function() {
    this._applyPath(this.oldPath);
};

TranslatePolygonCommand.prototype.getDescription = function() {
    return qsTr("Move Polygon");
};

TranslatePolygonCommand.prototype.canMergeWith = function(other) {
    return other instanceof TranslatePolygonCommand &&
           other.entityId === this.entityId &&
           (other.timestamp - this.timestamp) < 300;
};

TranslatePolygonCommand.prototype.mergeWith = function(other) {
    this.newPath = other.newPath;
    this.timestamp = other.timestamp;
};

TranslatePolygonCommand.prototype._applyPath = function(path) {
    const row = this._findEntityRow();
    if (row === -1) return;

    for (let i = 0; i < path.length; i++) {
        this.modelRef.setCoordinate(row, i, path[i]);
    }
};

TranslatePolygonCommand.prototype._findEntityRow = function() {
    const model = this.modelRef;
    for (let i = 0; i < model.rowCount(); i++) {
        const idx = model.index(i, 0);
        if (model.data(idx, model.IdRole) === this.entityId) {
            return i;
        }
    }
    return -1;
};
