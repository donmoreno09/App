.pragma library

Qt.include("qrc:/App/Features/MapModes/commands/ICommand.js")

/**
 * Command: Insert vertex at midpoint during polygon editing
 *
 * This command is fired when user drags a midpoint handle.
 * The vertex is already inserted during the drag (for immediate feedback).
 * This command is only for undo/redo support.
 *
 * Works with both:
 * - CreatePolygonMode's coordinatesModel (creation mode)
 * - PoiModel's coordinates (edit mode)
 */
function InsertPolygonVertexCommand(modeRef, insertIndex, originalMidpoint, finalVertex) {
    this.modeRef = modeRef;              // Reference to CreatePolygonMode or EditPolygonMode
    this.insertIndex = insertIndex;       // Where to insert (0-based index)
    this.originalMidpoint = originalMidpoint;  // Where the midpoint originally was
    this.finalVertex = finalVertex;       // Where user dragged it to
    this.timestamp = Date.now();

    console.log("[InsertPolygonVertexCommand] Created:",
        "index:", insertIndex,
        "from:", originalMidpoint.latitude, originalMidpoint.longitude,
        "to:", finalVertex.latitude, finalVertex.longitude)
}

InsertPolygonVertexCommand.prototype = Object.create(ICommand.prototype);
InsertPolygonVertexCommand.prototype.constructor = InsertPolygonVertexCommand;

InsertPolygonVertexCommand.prototype.execute = function() {
    console.log("[InsertPolygonVertexCommand] execute() called - re-inserting vertex at index", this.insertIndex)

    // Note: On initial creation, this is NOT called because the vertex
    // was already inserted during the drag for immediate visual feedback.
    // This is only called during REDO operations.

    // Check if we have coordinatesModel (creation mode)
    if (this.modeRef.coordinatesModel) {
        this.modeRef.coordinatesModel.insert(this.insertIndex, this.finalVertex)
        this.modeRef._syncPathFromModel()
    }
    // Edit mode would be handled by the model directly

    console.log("[InsertPolygonVertexCommand] execute() completed, new count:", this.modeRef.coordinatesCount())
};

InsertPolygonVertexCommand.prototype.undo = function() {
    console.log("[InsertPolygonVertexCommand] undo() called - removing vertex at index", this.insertIndex)

    const count = this.modeRef.coordinatesCount()
    console.log("[InsertPolygonVertexCommand] Current coordinates count:", count)

    if (this.insertIndex >= 0 && this.insertIndex < count) {
        this.modeRef.removeCoordinate(this.insertIndex)
        console.log("[InsertPolygonVertexCommand] Vertex removed. New count:", this.modeRef.coordinatesCount())
    } else {
        console.warn("[InsertPolygonVertexCommand] undo() - invalid index:", this.insertIndex, "count:", count)
    }
};

InsertPolygonVertexCommand.prototype.getDescription = function() {
    return qsTr("Insert Polygon Vertex");
};

InsertPolygonVertexCommand.prototype.canMergeWith = function(other) {
    // Don't merge vertex insertions - each drag is intentional
    return false;
};

InsertPolygonVertexCommand.prototype.mergeWith = function(other) {
    // Not applicable
};
