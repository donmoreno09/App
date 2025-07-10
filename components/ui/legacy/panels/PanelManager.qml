pragma Singleton
import QtQuick 6.5

QtObject {
    /* stato interno */
    property var    activePanel   : null    // istanza di BaseTrackPanel
    property var    linkedMarker  : null    // marker a cui è ancorato
    property string currentUid    : ""      // iridess_uid corrente

    /**
     * Apre (o chiude) il pannello per la traccia richiesta.
     *   @param trackData  QVariantMap arrivato via MQTT (modelData del marker)
     *   @param marker     riferimento al Track.qml che ha emesso il tap
     */
    function openPanel(trackData, marker) {
        /* clic sullo stesso marker ⇒ chiudo */
        if (currentUid === trackData.iridess_uid) {
            closeCurrent()
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

        const parentObj = marker

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
        if (linkedMarker && linkedMarker.unlinkToPanel)
            linkedMarker.unlinkToPanel()

        if (activePanel)
            activePanel.destroy()

        activePanel  = null
        linkedMarker = null
        currentUid   = ""
    }
}
