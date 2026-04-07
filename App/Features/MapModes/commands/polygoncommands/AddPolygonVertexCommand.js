.pragma library

Qt.include("qrc:/App/Features/MapModes/commands/ICommand.js")

function AddPolygonVertexCommand(modeRef, coordinate) {
    this.modeRef = modeRef;
    this.coordinate = coordinate;
    this.timestamp = Date.now();
}

AddPolygonVertexCommand.prototype = Object.create(ICommand.prototype);
AddPolygonVertexCommand.prototype.constructor = AddPolygonVertexCommand;

AddPolygonVertexCommand.prototype.execute = function() {
    this.modeRef._addCoordinate(this.coordinate)
};

AddPolygonVertexCommand.prototype.undo = function() {
    const count = this.modeRef.coordinatesCount()

    if (count > 0) {
        this.modeRef.removeCoordinate(count - 1)
    }
};

AddPolygonVertexCommand.prototype.canMergeWith = function(other) {
    // Don't merge vertex additions - each click is intentional
    return false;
};

AddPolygonVertexCommand.prototype.mergeWith = function(other) {
    // Not applicable
};
