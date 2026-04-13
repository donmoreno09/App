// WindowRouter.qml
pragma Singleton
import QtQuick 6.8
import App.Logger 1.0
import "qrc:/App/Components/floating-window/windowRoutes.js" as Routes

QtObject {
    id: root

    // Global incremental z counter (if the window exposes .z)
    property int _zCounter: 100

    // Component cache so we do not recompile every time
    property var _componentCache: ({})           // routeName -> Component
    // Current instances
    property var _instances: ({})                // routeName -> [Item]

    signal windowOpened(string routeName, var item)
    signal windowClosed(string routeName, var item)

    // --- Public API -------------------------------------------------------

    function open(routeName, parentItem, props) {
        if (!Routes.has(routeName)) {
            AppLogger.withService("WINDOW-ROUTER").error("Route not found", { routeName: routeName })
            return null
        }
        if (!parentItem) {
            AppLogger.withService("WINDOW-ROUTER").error("Missing parent for route", { routeName: routeName })
            return null
        }

        const route = Routes.get(routeName)

        // If singleton and already open, bring it to front and return it.
        const list = _instances[routeName] || []
        if (route.singleton && list.length > 0) {
            const inst = list[0]
            _bringToFront(inst)
            AppLogger.withService("WINDOW-ROUTER").warn("Route already open (singleton). Bringing it to front.", {
                routeName: routeName
            })
            return inst
        }

        // Prepare (or fetch from cache) the Component.
        let comp = _componentCache[routeName]
        if (!comp) {
            comp = Qt.createComponent(route.url)
            if (comp.status === Component.Loading) {
                comp.statusChanged.connect(function() {
                    // Keep open() synchronous, but leave a hook here if needed.
                })
            }
            _componentCache[routeName] = comp
        }

        if (comp.status === Component.Error) {
            AppLogger.withService("WINDOW-ROUTER").error("Component error", {
                routeName: routeName,
                error: comp.errorString()
            })
            return null
        }
        if (comp.status !== Component.Ready) {
            AppLogger.withService("WINDOW-ROUTER").warn("Component not ready", {
                routeName: routeName,
                status: comp.status
            })
            return null
        }

        // Final props: route defaults + caller props.
        const finalProps = Object.assign({}, route.defaultProps || {}, props || {})
        if (finalProps.parentWindow === undefined)
            finalProps.parentWindow = parentItem

        const item = comp.createObject(parentItem, finalProps)
        if (!item) {
            AppLogger.withService("WINDOW-ROUTER").error("createObject() failed", { routeName: routeName })
            return null
        }

        if (!_instances[routeName])
            _instances[routeName] = []
        _instances[routeName].push(item)

        item.Component.destruction.connect(function() {
            _untrack(routeName, item)
            root.windowClosed(routeName, item)
            // AppLogger.withService("WINDOW-ROUTER").info("closed", { routeName: routeName })
        })

        if (item && item.closeRequested) {
            item.closeRequested.connect(function() {
                _safeDestroy(item)
            })
        }

        _bringToFront(item)

        root.windowOpened(routeName, item)
        // AppLogger.withService("WINDOW-ROUTER").info("opened", { routeName: routeName })
        return item
    }

    function close(routeName, key) {
        const list = _instances[routeName]
        if (!list || list.length === 0) return

        if (key === undefined || key === null) {
            const it = list[0]
            _safeDestroy(it)
            return
        }

        if (typeof key === "number") {
            const it = list[key]
            if (it) _safeDestroy(it)
        } else if (key && key.destroy) {
            _safeDestroy(key)
        }
    }

    function closeAll(routeName) {
        const list = _instances[routeName]
        if (!list || list.length === 0) return

        const copy = list.slice()
        for (var i = 0; i < copy.length; ++i)
            _safeDestroy(copy[i])
    }

    function getOpen(routeName) {
        return (_instances[routeName] || []).slice()
    }

    // --- Helpers ----------------------------------------------------------

    function _safeDestroy(item) {
        try {
            if (item && item.destroy)
                item.destroy()
        } catch (e) {
            AppLogger.withService("WINDOW-ROUTER").warn("destroy() exception", { error: String(e) })
        }
    }

    function _untrack(routeName, item) {
        const list = _instances[routeName]
        if (!list) return
        const idx = list.indexOf(item)
        if (idx >= 0) list.splice(idx, 1)
        if (list.length === 0) delete _instances[routeName]
    }

    function _bringToFront(item) {
        if (item && item.forceActiveFocus) item.forceActiveFocus()
        if (item && item.hasOwnProperty("z")) {
            _zCounter += 1
            item.z = _zCounter
        }
        if (item && item.bringToFrontRequested) {
            try { item.bringToFrontRequested() } catch (e) {}
        }
    }
}
