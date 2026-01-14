pragma Singleton

import QtQuick 6.8
import App.Features.Language 1.0
import "PolygonCommands.js" as PolygonCommands

QtObject {
    id: root

    // Configuration
    readonly property int maxStackSize: 50

    // State
    property var commandStack: []
    property int currentIndex: -1

    readonly property bool canUndo: currentIndex >= 0
    readonly property bool canRedo: currentIndex < commandStack.length - 1

    // UI feedback
    readonly property string undoDescription: canUndo && commandStack[currentIndex]
        ? commandStack[currentIndex].getDescription()
        : ""
    readonly property string redoDescription: canRedo && commandStack[currentIndex + 1]
        ? commandStack[currentIndex + 1].getDescription()
        : ""

    signal stackChanged()

    /**
     * Execute a new command and add it to history
     * @param {ICommand} command
     */

    function executeCommand(command) {
        if (!command) {
            console.error("[CommandManager] Null command")
            return
        }

        console.log("[CommandManager] executeCommand() called:", command.getDescription())

        // Try to merge with previous command
        if (canUndo && commandStack[currentIndex].canMergeWith(command)) {
            console.log("[CommandManager] Merging with previous command")
            commandStack[currentIndex].mergeWith(command)
            commandStack[currentIndex].execute()
            return
        }

        // Clear redo history if we're not at the top
        if (currentIndex < commandStack.length - 1) {
            console.log("[CommandManager] Clearing redo history from index:", currentIndex + 1)
            commandStack.splice(currentIndex + 1)
        }

        // Execute the command
        console.log("[CommandManager] Executing command...")
        command.execute()

        // Add to stack (reassign to trigger QML binding updates)
        commandStack = [...commandStack, command]
        currentIndex++

        console.log("[CommandManager] Command added. Stack size:", commandStack.length, "Current index:", currentIndex)

        // Enforce max stack size
        if (commandStack.length > maxStackSize) {
            console.log("[CommandManager] Max stack size reached, removing oldest")
            commandStack.shift()
            currentIndex--
        }

        stackChanged()
    }

    /**
     * Undo the last command
     */
    function undo() {
        console.log("[CommandManager] undo() called. canUndo:", canUndo, "currentIndex:", currentIndex)

        if (!canUndo) {
            console.warn("[CommandManager] Cannot undo - stack empty or at beginning")
            return
        }

        console.log("[CommandManager] Undoing command:", commandStack[currentIndex].getDescription())
        commandStack[currentIndex].undo()
        currentIndex--

        console.log("[CommandManager] After undo - currentIndex:", currentIndex)

        stackChanged()
    }

    /**
     * Redo the next command
     */
    function redo() {
        console.log("[CommandManager] redo() called. canRedo:", canRedo, "currentIndex:", currentIndex)

        if (!canRedo) {
            console.warn("[CommandManager] Cannot redo - no redo history")
            return
        }

        currentIndex++
        console.log("[CommandManager] Redoing command:", commandStack[currentIndex].getDescription())
        commandStack[currentIndex].execute()

        console.log("[CommandManager] After redo - currentIndex:", currentIndex)

        stackChanged()
    }

    /**
     * Clear all history
     */
    function clear() {
        commandStack = [];
        currentIndex = -1;
        stackChanged();
    }

    /**
     * Get stack info for debugging
     */
    function printStack() {
        console.log("[CommandManager] Stack size:", commandStack.length);
        console.log("[CommandManager] Current index:", currentIndex);
        for (let i = 0; i < commandStack.length; i++) {
            const marker = i === currentIndex ? "→" : " ";
            console.log(marker, i, commandStack[i].getDescription());
        }
    }
}
