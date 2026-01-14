.pragma library

/**
 * ICommand Interface
 *
 * Represents a reversible action that can be executed, undone, and redone.
 * All concrete commands must implement these methods.
 */

/**
 * @interface ICommand
 */
function ICommand() {}

/**
 * Execute the command
 * @abstract
 */
ICommand.prototype.execute = function() {
    throw new Error("execute() must be implemented");
};

/**
 * Undo the command
 * @abstract
 */
ICommand.prototype.undo = function() {
    throw new Error("undo() must be implemented");
};

/**
 * Get a human-readable description of the command
 * @abstract
 * @returns {string}
 */
ICommand.prototype.getDescription = function() {
    throw new Error("getDescription() must be implemented");
};

/**
 * Check if this command can be merged with another
 * Useful for coalescing multiple small edits (e.g., dragging)
 * @abstract
 * @param {ICommand} other
 * @returns {boolean}
 */
ICommand.prototype.canMergeWith = function(other) {
    return false;
};

/**
 * Merge this command with another command
 * @abstract
 * @param {ICommand} other
 */
ICommand.prototype.mergeWith = function(other) {
    throw new Error("mergeWith() must be implemented");
};
