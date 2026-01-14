.pragma library

Qt.include("qrc:/App/Features/MapModes/commands/ICommand.js")

/**
 * Command: Update a single vertex coordinate in an existing polygon
 *
 * This command is fired when a user drags a polygon vertex handle in edit mode.
 * Works with AlertZoneModel (persistent state).
 */
function UpdatePolygonVertexCommand(modelRef, entityId, vertexIndex, oldCoord, newCoord) {
    this.modelRef = modelRef;      // Reference to AlertZoneModel
    this.entityId = entityId;       // ID of the alert zone
    this.vertexIndex = vertexIndex; // Which vertex (0-based)
    this.oldCoord = oldCoord;       // Previous coordinate {latitude, longitude}
    this.newCoord = newCoord;       // New coordinate {latitude, longitude}
    this.timestamp = Date.now();    // For merge coalescing
}

UpdatePolygonVertexCommand.prototype = Object.create(ICommand.prototype);
UpdatePolygonVertexCommand.prototype.constructor = UpdatePolygonVertexCommand;

UpdatePolygonVertexCommand.prototype.execute = function() {
    const row = this._findEntityRow();
    if (row === -1) {
        console.error("[UpdatePolygonVertexCommand] Entity not found:", this.entityId);
        return;
    }

    this.modelRef.setCoordinate(row, this.vertexIndex, this.newCoord);
};

UpdatePolygonVertexCommand.prototype.undo = function() {
    const row = this._findEntityRow();
    if (row === -1) {
        console.error("[UpdatePolygonVertexCommand] Entity not found:", this.entityId);
        return;
    }

    this.modelRef.setCoordinate(row, this.vertexIndex, this.oldCoord);
};

UpdatePolygonVertexCommand.prototype.getDescription = function() {
    return qsTr("Move Polygon Vertex");
};

UpdatePolygonVertexCommand.prototype.canMergeWith = function(other) {
    // Merge if same vertex edited within 300ms (prevents 100 commands for one drag)
    return other instanceof UpdatePolygonVertexCommand &&
           other.entityId === this.entityId &&
           other.vertexIndex === this.vertexIndex &&
           (other.timestamp - this.timestamp) < 300;
};

UpdatePolygonVertexCommand.prototype.mergeWith = function(other) {
    // Take the latest newCoord but keep original oldCoord
    this.newCoord = other.newCoord;
    this.timestamp = other.timestamp;
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
