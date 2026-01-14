.pragma library

Qt.include("qrc:/App/Features/MapModes/commands/ICommand.js")

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
