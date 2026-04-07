.pragma library

Qt.include("qrc:/App/Features/MapModes/commands/ICommand.js")

function UpdatePolygonVertexCommand(modelRef, entityId, oldPath, newPath) {
    this.modelRef = modelRef;
    this.entityId = entityId;
    this.oldPath = oldPath;
    this.newPath = newPath;
    this.timestamp = Date.now();
}

UpdatePolygonVertexCommand.prototype = Object.create(ICommand.prototype);
UpdatePolygonVertexCommand.prototype.constructor = UpdatePolygonVertexCommand;

UpdatePolygonVertexCommand.prototype.execute = function() {
    this._applyPath(this.newPath);
};

UpdatePolygonVertexCommand.prototype.undo = function() {
    this._applyPath(this.oldPath);
};

UpdatePolygonVertexCommand.prototype.canMergeWith = function(other) {
    return other instanceof UpdatePolygonVertexCommand &&
           other.entityId === this.entityId &&
           (other.timestamp - this.timestamp) < 300;
};

UpdatePolygonVertexCommand.prototype.mergeWith = function(other) {
    this.newPath = other.newPath;
    this.timestamp = other.timestamp;
};

UpdatePolygonVertexCommand.prototype._applyPath = function(path) {
    const row = this._findEntityRow();
    if (row === -1) return;

    for (let i = 0; i < path.length; i++) {
        this.modelRef.setCoordinate(row, i, path[i]);
    }
};

UpdatePolygonVertexCommand.prototype._findEntityRow = function() {
    const model = this.modelRef;
    for (let i = 0; i < model.rowCount(); i++) {
        const idx = model.index(i, 0);
        if (model.data(idx, model.IdRole) === this.entityId) {
            return i;
        }
    }
    return -1;
};
