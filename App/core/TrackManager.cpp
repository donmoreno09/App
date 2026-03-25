#include "TrackManager.h"
#include <connections/apiendpoints.h>

TrackManager* TrackManager::s_instance = nullptr;

TrackManager::TrackManager(QObject* parent) : QObject(parent) { s_instance = this; }

TrackManager* TrackManager::instance()
{
    // Note: returns nullptr if the QML engine hasn't created the singleton yet.
    return s_instance;
}

void TrackManager::initialize(HttpClient* http)
{
    m_http = http;
}

void TrackManager::registerLayer(const QString &track, QObject *layer)
{
    auto* casted = qobject_cast<BaseTrackMapLayer*>(layer);
    if (casted) {
        m_trackToLayer.insert(track, casted);
        qDebug() << "[TrackManager] Registered layer of track: " << track;
    } else {
        qWarning() << "[TrackManager] Error: Invalid layer to register for track: " << track;
    }
}

void TrackManager::unregisterLayer(const QString &track)
{
    m_trackToLayer.remove(track);
}

void TrackManager::activate(const QString &track)
{
    if (!m_http) return;

    m_http->post(ApiEndpoints::TrackSenderStart(track), QByteArray{}, [this, track](QRestReply& reply) {
        if (!reply.isSuccess()) {
            qWarning() << "[TrackManager] Failed to activate track '" << track << "': HTTP" << reply.httpStatus() << reply.errorString();
            return;
        }
        if (m_trackToLayer.contains(track)) {
            m_trackToLayer.value(track)->setActive(true);
            emit activated(track);
        }
    });
}

void TrackManager::activateHistory(const QString &topic, const QString &track_iridess_uidd)
{
    if (!m_http) return;

    m_http->post(ApiEndpoints::TrackHistorySenderStart(topic, track_iridess_uidd), QByteArray{}, [this, topic, track_iridess_uidd](QRestReply& reply) {
        if (!reply.isSuccess()) {
            qWarning() << "[TrackManager] Failed to activate track history for '" << topic << "': HTTP" << reply.httpStatus() << reply.errorString();
            const QString k = key(topic, track_iridess_uidd);
            m_histState.insert(k, Inactive);
            emit historyStateChanged(topic, track_iridess_uidd, Inactive);
            return;
        }
        qDebug() << "[TrackManager] Activate History request OK (awaiting payload)";
        emit activatedHistory(topic, track_iridess_uidd);
    });
}

void TrackManager::deactivate(const QString &track)
{
    if (!m_http) return;

    m_http->post(ApiEndpoints::TrackSenderStop(track), QByteArray{}, [this, track](QRestReply& reply) {
        if (!reply.isSuccess()) {
            if (reply.httpStatus() != 404)
                qWarning() << "[TrackManager] Failed to deactivate track '" << track << "': HTTP" << reply.httpStatus() << reply.errorString();
            return;
        }
        if (m_trackToLayer.contains(track)) {
            m_trackToLayer.value(track)->setActive(false);
            emit deactivated(track);
        }
    });
}

void TrackManager::deactivateHistory(const QString &topic, const QString &track_iridess_uid)
{
    if (!m_http) return;

    m_http->post(ApiEndpoints::TrackHistorySenderStop(topic, track_iridess_uid), QByteArray{}, [this, topic, track_iridess_uid](QRestReply& reply) {
        if (!reply.isSuccess()) {
            qWarning() << "[TrackManager] Failed to deactivate track history for '" << topic << "': HTTP" << reply.httpStatus() << reply.errorString();
            return;
        }
        qDebug() << "[TrackManager] Deactivate History OK";
        emit deactivatedHistory(topic, track_iridess_uid);
        const QString k = key(topic, track_iridess_uid);
        m_histState.insert(k, Inactive);
        emit historyStateChanged(topic, track_iridess_uid, Inactive);
        emit requestClearHistory(topic, track_iridess_uid);
    });
}


BaseTrackMapLayer* TrackManager::getLayer(const QString &track)
{
    return m_trackToLayer.value(track);
}

int TrackManager::historyState(const QString& topic, const QString& uid) const
{
    return m_histState.value(key(topic, uid), Inactive);
}

void TrackManager::setHistoryActive(const QString& topic, const QString& uid, bool on)
{
    const QString k = key(topic, uid);
    const HistoryState cur = m_histState.value(k, Inactive);
    const HistoryState next = on ? Loading : Inactive;
    if (cur == next) return;

    // Update local state and notify UI immediately.
    m_histState.insert(k, next);
    emit historyStateChanged(topic, uid, next);

    if (on) {
        // Fire the backend request to start history.
        activateHistory(topic, uid);
        // We stay in Loading until onHistoryPayloadArrived(...) promotes to Active.
    } else {
        // Fire the backend request to stop history.
        deactivateHistory(topic, uid);
        // Ask consumers to clear local history right away for instant visual feedback.
        emit requestClearHistory(topic, uid);
    }
}

void TrackManager::onHistoryPayloadArrived(const QString& topic, const QString& uid)
{
    // This should be called when your data pipeline detects the FIRST payload with "history"
    // for (topic, uid). It promotes Loading -> Active exactly once.
    const QString k = key(topic, uid);
    if (m_histState.value(k, Inactive) == Loading) {
        m_histState.insert(k, Active);
        emit historyStateChanged(topic, uid, Active);
    }
}
