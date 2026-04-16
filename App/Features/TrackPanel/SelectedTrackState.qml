pragma Singleton
import QtQuick 6.8
import App

QtObject {
    id: root

    property QtObject _liveItem: null
    property bool _syncing: false

    // The snapshot — what the panel binds to.
    // Populated on select(); frozen when the track enters a cluster.
    readonly property QtObject selectedItem: QtObject {
        property string name: ""
        property var    pos: null
        property double cog: 0
        property var    vel: null
        property int    time: 0
        property string sourceName: ""
        property string uidForHistory: ""
        property string trackUid: ""
    }

    function deselect() {
        if (_liveItem)
            _liveItem.valueChanged.disconnect(_onValueChanged)
        _liveItem = null
        _syncing = false
        selectedItem.name          = ""
        selectedItem.pos           = null
        selectedItem.cog           = 0
        selectedItem.vel           = null
        selectedItem.time          = 0
        selectedItem.sourceName    = ""
        selectedItem.uidForHistory = ""
        selectedItem.trackUid      = ""
    }

    function select(item: QtObject) {
        if (_liveItem)
            _liveItem.valueChanged.disconnect(_onValueChanged)

        _liveItem = item
        _syncAll()
        _syncing = true

        if (_liveItem)
            _liveItem.valueChanged.connect(_onValueChanged)
    }

    function _syncAll() {
        if (!_liveItem) return
        selectedItem.name          = _liveItem.name          ?? ""
        selectedItem.pos           = _liveItem.pos
        selectedItem.cog           = _liveItem.cog           ?? 0
        selectedItem.vel           = _liveItem.vel
        selectedItem.time          = _liveItem.time          ?? 0
        selectedItem.sourceName    = _liveItem.sourceName    ?? ""
        selectedItem.uidForHistory = _liveItem.uidForHistory ?? ""
        selectedItem.trackUid      = _liveItem.trackUid      ?? ""
        console.log("[SelectedTrackState] selected track:",
                    "trackUid=" + selectedItem.trackUid,
                    "name=" + selectedItem.name,
                    "cog=" + selectedItem.cog,
                    "pos=" + JSON.stringify(selectedItem.pos))
    }

    function _onValueChanged(key, value) {
        if (!_syncing) return
        if (selectedItem[key] !== undefined)
            selectedItem[key] = value
    }
}
