import QtQuick 6.8
import QtQuick.Controls 6.8

QtObject {
    id: root

    required property var routes

    property StackView stackView: null
    property string currentPath: ""
    property string previousPath: ""

    signal stackWillChange(int currentDepth, int nextDepth, string fromPath, string toPath)
    signal stackChanged(int depth, string currentPath)
    signal routeMissing(string path)

    // Internal: mirror of route paths to keep currentPath on pop/replace
    property var _pathStack: []

    function _emitStackWillChange(nextDepth, toPath) {
        const currentDepth = stackView ? stackView.depth : 0
        const fromPath = _pathStack.length ? _pathStack[_pathStack.length - 1] ?? "" : ""
        root.stackWillChange(currentDepth, nextDepth, fromPath, toPath ?? "")
    }

    function _emitStackChanged() {
        const depth = stackView ? stackView.depth : 0
        const newPath = _pathStack.length ? _pathStack[_pathStack.length - 1] ?? "" : ""
        previousPath = currentPath
        currentPath = newPath
        root.stackChanged(depth, currentPath)
    }

    function clear() {
        if (!stackView) {
            console.warn("[PanelRouter] No StackView registered")
            return
        }

        _emitStackWillChange(0, "")
        stackView.clear()
        _pathStack = []
        _emitStackChanged()
    }

    function push(path, props) {
        if (!stackView) {
            console.warn("[PanelRouter] No StackView registered")
            return
        }

        const url = routes.resolve(path)
        if (!url) {
            routeMissing(path)
            return
        }

        const nextDepth = (stackView ? stackView.depth : 0) + 1

        // StackView accepts URL + optional properties
        _emitStackWillChange(nextDepth, path)
        stackView.push(url, props || {})
        _pathStack.push(path)
        _emitStackChanged()
    }

    function pop() {
        if (!stackView) {
            console.warn("[PanelRouter] No StackView registered")
            return
        }

        if (stackView.depth <= 0) return

        const nextDepth = Math.max(0, stackView.depth - 1)
        const nextPath = _pathStack.length > 1 ? _pathStack[_pathStack.length - 2] : ""

        _emitStackWillChange(nextDepth, nextPath)
        stackView.pop()
        if (_pathStack.length) _pathStack.pop()
        _emitStackChanged()
    }

    function replace(path, props) {
        if (!stackView) {
            console.warn("[PanelRouter] No StackView registered")
            return
        }

        const url = routes.resolve(path)
        if (!url) {
            routeMissing(path)
            return
        }

        _emitStackWillChange(1, path)
        stackView.clear()
        _pathStack = []
        stackView.push(url, props || {})
        _pathStack.push(path)
        _emitStackChanged()
    }

    function replaceCurrent(path, props) {
        if (!stackView) {
            console.warn("[PanelRouter] No StackView registered")
            return
        }

        const url = routes.resolve(path)
        if (!url) {
            routeMissing(path)
            return
        }

        if (stackView.depth > 0) {
            _emitStackWillChange(stackView.depth, path)
            stackView.replace(url, props || {})
            if (_pathStack.length) _pathStack[_pathStack.length - 1] = path
            else _pathStack.push(path)
        } else {
            // nothing on stack - behave like replace()
            _emitStackWillChange(1, path)
            stackView.clear()
            _pathStack = []
            stackView.push(url, props || {})
            _pathStack.push(path)
        }

        _emitStackChanged()
    }
}
