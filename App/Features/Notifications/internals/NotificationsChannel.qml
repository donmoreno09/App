// NOTE: This is a POC component.
//
// Notifications will be properly analyzed
// later. The main idea is to have notifications
// be handled inside a C++ controller using
// Qt's model/view architecture.

import QtQuick 6.8

QtObject {
    readonly property ListModel _model: ListModel { }

    readonly property int count: _model.count

    function push(context) {
        _model.append(context)
    }

    function pop() {
        if (!_model.count) return null

        const index = _model.count - 1
        const item = _model.get(index)
        _model.remove(index)
        return item
    }

    function clear() {
        _model.clear()
    }
}
