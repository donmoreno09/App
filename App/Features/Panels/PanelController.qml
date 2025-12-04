import QtQuick 6.8

QtObject {
    id: root

    // Properties
    required property PanelRouter router

    property bool isOpen: false
    property var _currentPanel: null
    property var _currentStackView: null

    // Signals
    signal opening()
    signal opened()
    signal closing()
    signal closed()
    signal routeChanged(string path)

    // Methods
    // Reopen the panel without recreating the current route if possible.
    function show(path, props) {
        if (isOpen) return

        const targetPath = (path === undefined || path === null) ? (router.currentPath ?? "") : path
        const hasStack = router.stackView && router.stackView.depth > 0
        const canReuse = hasStack && router.currentPath === targetPath && targetPath !== ""

        if (!canReuse) {
            open(targetPath, props)
            return
        }

        opening()
        isOpen = true
        opened()
    }

    function open(path, props) {
        if (isOpen) return

        opening()
        if (path == null) path = router.currentPath ?? ""
        router.replace(path, props || {})
        isOpen = true
        opened()
    }

    function toggle(path, props) {
        if (!isOpen) {
            const targetPath = (path === undefined || path === null) ? (router.currentPath ?? "") : path
            const hasStack = router.stackView && router.stackView.depth > 0
            const canReuse = hasStack && router.currentPath === targetPath && targetPath !== ""

            if (canReuse) show(targetPath, props)
            else open(path, props)
            return
        }

        if (router.currentPath === path) {
            close()
            return
        }

        router.replace(path, props || {})
    }

    function close(destroy) {
        if (!isOpen) return

        closing()
        isOpen = false
        if (destroy) router.clear()
        closed()
    }

    function openOrRefresh(path, props) {
        if (!path) {
            path = router.currentPath ?? ""
        }

        if (!isOpen) {
            open(path, props)
            return
        }

        if (router.currentPath === path) {
            // force a refresh of props even if route is the same
            router.replace(path, props || {})
            return
        }

        close()
        open(path, props)
    }

    function _bindPanel(item) {
        if (!item && _currentStackView) item = _currentStackView.currentItem
        if (_currentPanel && _currentPanel.requestClose) {
            _currentPanel.requestClose.disconnect(_onPanelRequestClose)
        }
        _currentPanel = item
        if (_currentPanel && _currentPanel.requestClose) {
            _currentPanel.requestClose.connect(_onPanelRequestClose)
        }
    }

    function _onDepthChanged() {
        if (!_currentStackView) return
        _bindPanel(_currentStackView.currentItem)
    }

    function _attachStackView() {
        if (_currentStackView) {
            _currentStackView.currentItemChanged.disconnect(_bindPanel)
            _currentStackView.depthChanged.disconnect(_onDepthChanged)
        }

        _currentStackView = router.stackView

        if (!_currentStackView) {
            _bindPanel(null)
            return
        }

        _bindPanel(_currentStackView.currentItem)
        _currentStackView.currentItemChanged.connect(_bindPanel)
        _currentStackView.depthChanged.connect(_onDepthChanged)
    }

    function _onStackChanged(depth: int, currentPath: string) {
        root.routeChanged(currentPath)
    }

    function _onPanelRequestClose(destroy: bool) { root.close(destroy) }

    Component.onCompleted: {
        router.stackChanged.connect(_onStackChanged)
        router.stackViewChanged.connect(_attachStackView)
        if (router.stackView) _attachStackView(router.stackView)
    }

    Component.onDestruction: {
        router.stackChanged.disconnect(_onStackChanged)
        router.stackViewChanged.disconnect(_attachStackView)
        _bindPanel(null)
        if (_currentStackView) {
            _currentStackView.currentItemChanged.disconnect(_bindPanel)
            _currentStackView.depthChanged.disconnect(_onDepthChanged)
        }
    }
}
