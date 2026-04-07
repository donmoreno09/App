.pragma library

function ICommand() {}

ICommand.prototype.execute = function() {
    throw new Error("execute() must be implemented");
};

ICommand.prototype.undo = function() {
    throw new Error("undo() must be implemented");
};

ICommand.prototype.canMergeWith = function(other) {
    return false;
};

ICommand.prototype.mergeWith = function(other) {
    throw new Error("mergeWith() must be implemented");
};
