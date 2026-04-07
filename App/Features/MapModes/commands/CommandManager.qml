pragma Singleton

import QtQuick 6.8
import App.Features.Language 1.0
import "PolygonCommands.js" as PolygonCommands

QtObject {
    id: root

    readonly property int maxStackSize: 50

    property var commandStack: []
    property int currentIndex: -1

    readonly property bool canUndo: currentIndex >= 0
    readonly property bool canRedo: currentIndex < commandStack.length - 1

    signal stackChanged()

    function executeCommand(command) {
        if (!command) {
            console.error("[CommandManager] Null command")
            return
        }

        if (canUndo && commandStack[currentIndex] && commandStack[currentIndex].canMergeWith(command)) {
            commandStack[currentIndex].mergeWith(command)
            commandStack[currentIndex].execute()
            stackChanged()
            return
        }

        if (currentIndex < commandStack.length - 1) {
            commandStack = commandStack.slice(0, currentIndex + 1)
        }

        command.execute()

        commandStack = [...commandStack, command]
        currentIndex++

        if (commandStack.length > maxStackSize) {
            commandStack = commandStack.slice(1)
            currentIndex--
        }

        stackChanged()
    }

    function undo() {
        if (!canUndo || !commandStack[currentIndex]) {
            console.warn("[CommandManager] Cannot undo - stack empty or at beginning")
            return
        }

        commandStack[currentIndex].undo()
        currentIndex--

        stackChanged()
    }

    function redo() {
        if (!canRedo || !commandStack[currentIndex + 1]) {
            console.warn("[CommandManager] Cannot redo - no redo history")
            return
        }

        currentIndex++
        commandStack[currentIndex].execute()

        stackChanged()
    }

    function clear() {
        commandStack = [];
        currentIndex = -1;
        stackChanged();
    }

    // Get stack info for debugging
    // function printStack() {
    //     console.log("[CommandManager] Stack size:", commandStack.length);
    //     console.log("[CommandManager] Current index:", currentIndex);
    //     for (let i = 0; i < commandStack.length; i++) {
    //         const marker = i === currentIndex ? "→" : " ";
    //         console.log(marker, i, "Command");
    //     }
    // }
}
