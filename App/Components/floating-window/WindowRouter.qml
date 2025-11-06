// WindowRouter.qml
pragma Singleton
import QtQuick 6.8
import "qrc:/App/Components/floating-window/windowRoutes.js" as Routes

QtObject {
    id: root

    // Z “globale” incrementale (se la finestra espone .z)
    property int _zCounter: 100

    // Cache dei Component per non ricompilare ogni volta
    property var _componentCache: ({})           // routeName -> Component
    // Istanzati correnti
    property var _instances: ({})                // routeName -> [Item]

    signal windowOpened(string routeName, var item)
    signal windowClosed(string routeName, var item)

    // --- API pubblica -------------------------------------------------------

    function open(routeName, parentItem, props) {
        if (!Routes.has(routeName)) {
            console.error("[WindowRouter] Route non trovata:", routeName)
            return null
        }
        if (!parentItem) {
            console.error("[WindowRouter] Parent mancante per route:", routeName)
            return null
        }

        const route = Routes.get(routeName)

        // Se singleton ed esiste già: porta davanti e ritorna
        const list = _instances[routeName] || []
        if (route.singleton && list.length > 0) {
            const inst = list[0]
            _bringToFront(inst)
            console.warn("[WindowRouter] Route", routeName, "già aperta (singleton). Riporto in primo piano.")
            return inst
        }

        // Prepara (o prendi dalla cache) il Component
        let comp = _componentCache[routeName]
        if (!comp) {
            comp = Qt.createComponent(route.url)
            if (comp.status === Component.Loading) {
                comp.statusChanged.connect(function() {
                    // Evitiamo di non avere feedback: ma manteniamo open() sincrona
                })
            }
            _componentCache[routeName] = comp
        }

        if (comp.status === Component.Error) {
            console.error("[WindowRouter] Errore Component per", routeName, ":", comp.errorString())
            return null
        }
        if (comp.status !== Component.Ready) {
            console.warn("[WindowRouter] Component non pronto per", routeName, "status:", comp.status)
            return null
        }

        // Props finali: default della route + props chiamante
        const finalProps = Object.assign({}, route.defaultProps || {}, props || {})
        // Tipico per i tuoi container: passa anche parentWindow se serve
        if (finalProps.parentWindow === undefined)
            finalProps.parentWindow = parentItem

        const item = comp.createObject(parentItem, finalProps)
        if (!item) {
            console.error("[WindowRouter] createObject() fallita per", routeName)
            return null
        }

        // tracking
        if (!_instances[routeName])
            _instances[routeName] = []
        _instances[routeName].push(item)

        // cleanup on destruction
        item.Component.destruction.connect(function() {
            _untrack(routeName, item)
            root.windowClosed(routeName, item)
            // console.log("[WindowRouter] closed:", routeName)
        })
        // Se la finestra espone il segnale closeRequested, connettilo a destroy()
        if (item && item.closeRequested) {
            item.closeRequested.connect(function() {
                _safeDestroy(item)
            })
        }
        // porta davanti (se ha .z)
        _bringToFront(item)

        root.windowOpened(routeName, item)
        // console.log("[WindowRouter] opened:", routeName)
        return item
    }

    function close(routeName, key) {
        const list = _instances[routeName]
        if (!list || list.length === 0) return

        if (key === undefined || key === null) {
            // chiudi la prima (utile per singleton)
            const it = list[0]
            _safeDestroy(it)
            return
        }

        // key può essere l’istanza stessa o un indice
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
        // copia per evitare modifica mentre iteriamo
        const copy = list.slice()
        for (var i = 0; i < copy.length; ++i)
            _safeDestroy(copy[i])
    }

    function getOpen(routeName) {
        return (_instances[routeName] || []).slice()
    }

    // --- Helpers -------------------------------------------------------------

    function _safeDestroy(item) {
        try {
            if (item && item.destroy)
                item.destroy()
        } catch (e) {
            console.warn("[WindowRouter] destroy() exception:", e)
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
        // Porta a fuoco e incrementa z se disponibile
        if (item && item.forceActiveFocus) item.forceActiveFocus()
        if (item && item.hasOwnProperty("z")) {
            _zCounter += 1
            item.z = _zCounter
        }
        // Se il componente espone un segnale/metodo specifico, chiamalo:
        if (item && item.bringToFrontRequested) {
            try { item.bringToFrontRequested() } catch(e) {}
        }
    }
}
