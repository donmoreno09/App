pragma Singleton
import QtQuick 6.8

QtObject {
    /* stato interno */
    property var    activePanel   : null    // istanza di BaseTrackPanel
    property var    linkedMarker  : null    // marker a cui è ancorato
    property string currentUid    : ""      // iridess_uid corrente

    property var uiOverlay : null

    signal centerViewRequested(var coordinate)

    /**
     * Apre (o chiude) il pannello per la traccia richiesta.
     *   @param trackData  QVariantMap arrivato via MQTT (modelData del marker)
     *   @param marker     riferimento al Track.qml che ha emesso il tap
     */
    function openPanel(trackData, marker) {
        /* clic sullo stesso marker ⇒ chiudo oppure riapro se minimizzato */
        if (currentUid === trackData.iridess_uid) {
            if (activePanel && activePanel.isMinimized) {
                activePanel.unminimize()
            } else {
                closeCurrent()
            }
            return
        }

        closeCurrent()          // chiudi eventuale pannello precedente

        /* Instanzia il componente legacy */
        const comp = Qt.createComponent(
            Qt.resolvedUrl("./track/BaseTrackPanel.qml"))

        if (comp.status === Component.Error) {
            console.error("[PanelManager] load panel error: ", comp.errorString())
            return
        }

        const parentObj = uiOverlay

        activePanel = comp.createObject(parentObj, {
            trackData    : trackData,
            marker       : marker,
            trackUid     : trackData.iridess_uid,
            trackChannel : marker.channel || "smartport"
        })

        if (!activePanel) {
            console.error("[PanelManager] createObject panel failed:", panelComp.errorString())
            return
        }

        /* Carica link */
        const linkComp = Qt.createComponent(Qt.resolvedUrl("./track/BaseTrackPanelLink.qml"))
        if (linkComp.status === Component.Error) {
            console.warn("[PanelManager] link load error:", linkComp.errorString())
        }

        let linkObj = null
        if (linkComp.status === Component.Ready) {
            linkObj = linkComp.createObject(parentObj, {
                panelAnchor : Qt.point(0, 0),          // valori iniziali, verranno aggiornati
                markerAnchor: Qt.point(0, 0),
                color       : activePanel.bodyGradientColorEnd || "yellow"
            })
        }

        activePanel.closed.connect(function () {
            // After closing BaseTrackPanel (activePanel in this case)
            // This function will be called to handle cleanups associated
            // with this PanelManager.
            if (linkedMarker && linkedMarker.unlinkToPanel)
                linkedMarker.unlinkToPanel()

            activePanel  = null
            linkedMarker = null
            currentUid   = ""
        })

        activePanel.centerViewRequested.connect(centerViewRequested)

        /* Avvisa pannello e marker */
        if (activePanel.open)               // metodo già presente in legacy
            activePanel.open(marker, linkObj)

        if (marker.linkToPanel && linkObj)
            marker.linkToPanel(linkObj)


        linkedMarker = marker
        currentUid   = trackData.iridess_uid
    }

    /** Chiude e pulisce lo stato */
    function closeCurrent() {
        if (activePanel) {
            // This is an internal function of BaseTrackPanel
            // which cleans up and destroys itself.
            activePanel.close()
        }
    }
}
