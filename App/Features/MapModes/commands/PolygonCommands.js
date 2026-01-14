.pragma library

Qt.include("ICommand.js")

// ============================================================================
// CREATION MODE COMMANDS
// ============================================================================

/**
 * Command: Add vertex during polygon creation
 *
 * This command is fired when user clicks on map during creation mode.
 * Works with CreatePolygonMode's coordinatesModel (transient state).
 */
function AddPolygonVertexCommand(modeRef, coordinate) {
    this.modeRef = modeRef;          // Reference to CreatePolygonMode
    this.coordinate = coordinate;     // {latitude, longitude} or QGeoCoordinate
    this.timestamp = Date.now();
}

AddPolygonVertexCommand.prototype = Object.create(ICommand.prototype);
AddPolygonVertexCommand.prototype.constructor = AddPolygonVertexCommand;

AddPolygonVertexCommand.prototype.execute = function() {
    console.log("[AddPolygonVertexCommand] execute() called, coord:", this.coordinate.latitude, this.coordinate.longitude)

    // Just call the add function - don't try to access coordinatesModel
    this.modeRef._addCoordinate(this.coordinate)

    console.log("[AddPolygonVertexCommand] execute() completed successfully")
};

AddPolygonVertexCommand.prototype.undo = function() {
    console.log("[AddPolygonVertexCommand] undo() called")

    // Access coordinatesModel through the proper reference
    const count = this.modeRef.coordinatesCount()
    console.log("[AddPolygonVertexCommand] Current coordinates count:", count)

    if (count > 0) {
        // Remove the last coordinate using the exposed method
        this.modeRef.removeCoordinate(count - 1)
        console.log("[AddPolygonVertexCommand] Coordinate removed. New count:", this.modeRef.coordinatesCount())
    }
};

AddPolygonVertexCommand.prototype.getDescription = function() {
    return qsTr("Add Polygon Vertex");
};

AddPolygonVertexCommand.prototype.canMergeWith = function(other) {
    // Don't merge vertex additions - each click is intentional
    return false;
};

AddPolygonVertexCommand.prototype.mergeWith = function(other) {
    // Not applicable
};


/**
 * Command: Close polygon during creation
 *
 * This command is fired when user double-clicks or clicks first vertex.
 */
function ClosePolygonCommand(modeRef) {
    this.modeRef = modeRef;
    this.wasClosed = modeRef.closed; // Store previous state
}

ClosePolygonCommand.prototype = Object.create(ICommand.prototype);
ClosePolygonCommand.prototype.constructor = ClosePolygonCommand;

ClosePolygonCommand.prototype.execute = function() {
    this.modeRef._tryClose();
};

ClosePolygonCommand.prototype.undo = function() {
    this.modeRef.closed = this.wasClosed;
    this.modeRef.coordinatesChanged();
};

ClosePolygonCommand.prototype.getDescription = function() {
    return qsTr("Close Polygon");
};

ClosePolygonCommand.prototype.canMergeWith = function(other) {
    return false;
};

ClosePolygonCommand.prototype.mergeWith = function(other) {
    // Not applicable
};


// ============================================================================
// EDITING MODE COMMANDS
// ============================================================================

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
    // Import PolygonGeometry for applyPathToModel
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
