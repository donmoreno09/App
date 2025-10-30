pragma Singleton

import QtQuick 6.8
import QtQuick.Controls 6.8

import "qrc:/App/Features/SidePanel/routes.js" as Routes

QtObject {
    id: root

    property StackView stackView: null
    property string currentPath: ""

    signal stackChanged(int depth, string currentPath)
    signal routeMissing(string path)

    // Internal: mirror of route paths to keep currentPath on pop/replace
    property var _pathStack: []

    function _emitStackChanged() {
        const depth = stackView ? stackView.depth : 0
        currentPath = _pathStack.length ? _pathStack[_pathStack.length - 1] ?? "" : ""
        root.stackChanged(depth, currentPath)
    }

    function clear() {
        if (!stackView) {
            console.warn("[PanelRouter] No StackView registered")
            return
        }

        stackView.clear()
        _pathStack = []
        _emitStackChanged()
    }

    function push(path, props) {
        if (!stackView) {
            console.warn("[PanelRouter] No StackView registered")
            return
        }

        const url = Routes.resolve(path)
        if (!url) {
            routeMissing(path)
            return
        }

        // StackView accepts URL + optional properties
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

        stackView.pop()
        if (_pathStack.length) _pathStack.pop()
        _emitStackChanged()
    }

    function replace(path, props) {
        if (!stackView) {
            console.warn("[PanelRouter] No StackView registered")
            return
        }

        const url = Routes.resolve(path)
        if (!url) {
            routeMissing(path)
            return
        }

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

        const url = Routes.resolve(path)
        if (!url) {
            routeMissing(path)
            return
        }

        if (stackView.depth > 0) {
            stackView.replace(url, props || {})
            if (_pathStack.length) _pathStack[_pathStack.length - 1] = path
            else _pathStack.push(path)
        } else {
            // nothing on stack → behave like replace()
            stackView.clear()
            _pathStack = []
            stackView.push(url, props || {})
            _pathStack.push(path)
        }

        _emitStackChanged()
    }
}
