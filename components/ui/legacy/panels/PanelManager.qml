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

        activePanel = comp.createObject(Qt.application.activeWindow, {
            trackData    : trackData,
            marker       : marker,
            trackUid     : trackData.iridess_uid,
            trackChannel : marker.channel || "smartport"
        })

        /* Collega graficamente marker ↔ pannello */
        if (activePanel && marker && marker.linkToPanel) {
            /* BaseTrackPanel spesso crea internamente la “link” e la espone
               con una property   link: TrackPanelLink { … }                */
            if (activePanel.link)           // ↙︎ fallback per versioni legacy
                marker.linkToPanel(activePanel.link)
            else
                marker.linkToPanel(activePanel)   // se la link coincide col panel
        }

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
