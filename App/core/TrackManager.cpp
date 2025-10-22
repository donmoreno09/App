#include "TrackManager.h"
#include <QEventLoop>
#include <QTimer>
#include <connections/apiendpoints.h>

TrackManager* TrackManager::s_instance = nullptr;

TrackManager::TrackManager(QObject* parent) : QObject(parent) { s_instance = this; }

TrackManager* TrackManager::instance()
{
    // Note: returns nullptr if the QML engine hasn't created the singleton yet.
    return s_instance;
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
    const QUrl url(ApiEndpoints::TrackSenderStart(track));
    QNetworkReply* reply = m_networkManager.post(QNetworkRequest(url), QByteArray{});

    connect(reply, &QNetworkReply::finished, this, [this, reply, track]() {
        reply->deleteLater();

        if (reply->error() != QNetworkReply::NoError) {
            qWarning() << "[TrackManager] Failed to activate track '" << track << "':" << reply->errorString();
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
    const QUrl url(ApiEndpoints::TrackHistorySenderStart(topic, track_iridess_uidd));
    QNetworkReply* reply = m_networkManager.post(QNetworkRequest(url), QByteArray{});

    connect(reply, &QNetworkReply::finished, this, [this, reply, topic, track_iridess_uidd]() {
        reply->deleteLater();

        if (reply->error() != QNetworkReply::NoError) {
            qWarning() << "[TrackManager] Failed to activate track history for '" << topic << "':" << reply->errorString();

            // Rollback state to Inactive if the request itself failed.
            const QString k = key(topic, track_iridess_uidd);
            m_histState.insert(k, Inactive);
            emit historyStateChanged(topic, track_iridess_uidd, Inactive);

            return;
        }

        // Request accepted: keep state in Loading until first history payload arrives.
        qDebug() << "[TrackManager] Activate History request OK (awaiting payload)";
        emit activatedHistory(topic, track_iridess_uidd);
    });
}

void TrackManager::deactivate(const QString &track)
{
    const QUrl url(ApiEndpoints::TrackSenderStop(track));
    QNetworkReply* reply = m_networkManager.post(QNetworkRequest(url), QByteArray{});

    connect(reply, &QNetworkReply::finished, this, [this, reply, track]() {
        reply->deleteLater();

        if (reply->error() != QNetworkReply::NoError) {
            qWarning() << "[TrackManager] Failed to deactivate track '" << track << "':" << reply->errorString();
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
    const QUrl url(ApiEndpoints::TrackHistorySenderStop(topic, track_iridess_uid));
    QNetworkReply* reply = m_networkManager.post(QNetworkRequest(url), QByteArray{});

    connect(reply, &QNetworkReply::finished, this, [this, reply, topic, track_iridess_uid]() {
        reply->deleteLater();

        if (reply->error() != QNetworkReply::NoError) {
            qWarning() << "[TrackManager] Failed to deactivate track history for '" << topic << "':" << reply->errorString();
            return;
        }

        qDebug() << "[TrackManager] Deactivate History OK";
        emit deactivatedHistory(topic, track_iridess_uid);

        // Ensure the state is set to Inactive after a successful stop.
        const QString k = key(topic, track_iridess_uid);
        m_histState.insert(k, Inactive);
        emit historyStateChanged(topic, track_iridess_uid, Inactive);

        // Optional: ask views/models to clear local polyline immediately.
        emit requestClearHistory(topic, track_iridess_uid);
    });
}

void TrackManager::deactivateSync(const QString &track)
{
    QNetworkRequest request(ApiEndpoints::TrackSenderStop(track));
    QNetworkReply* reply = m_networkManager.post(request, QByteArray{});

    QEventLoop loop;
    QObject::connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);

    // Timeout opzionale per evitare blocchi infiniti
    QTimer timeoutTimer;
    timeoutTimer.setSingleShot(true);
    QObject::connect(&timeoutTimer, &QTimer::timeout, &loop, &QEventLoop::quit);
    timeoutTimer.start(3000); // max 3s

    loop.exec(); // blocca finché termina reply o timeout

    if (reply->error() != QNetworkReply::NoError) {
        qWarning() << "[TrackManager] Failed to deactivate track '" << track << "':" << reply->errorString();
    } else {
        if (m_trackToLayer.contains(track)) {
            m_trackToLayer.value(track)->setActive(false);
            emit deactivated(track);
        }
    }

    reply->deleteLater();
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
