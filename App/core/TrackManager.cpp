#include "TrackManager.h"
#include <connections/apiendpoints.h>

#include "AppLogger.h"

// Anonymous namespace to make _logger exclusive for this file
namespace {
Logger& _logger()
{
    static Logger logger = AppLogger::get().child({
        {"service", "TRACK-MANAGER"}
    });
    return logger;
}
}

TrackManager* TrackManager::s_instance = nullptr;

TrackManager::TrackManager(QObject* parent)
    : QObject(parent)
    , m_zoomSyncDebouncer(300, this)
{ s_instance = this; }

TrackManager* TrackManager::instance()
{
    // Note: returns nullptr if the QML engine hasn't created the singleton yet.
    return s_instance;
}

void TrackManager::initialize(HttpClient* http)
{
    if (!http) {
        _logger().error("initialize() called with null client");
        return;
    }

    m_http = http;
}

void TrackManager::registerLayer(const QString &track, QObject *layer)
{
    auto* casted = qobject_cast<BaseTrackMapLayer*>(layer);
    if (casted) {
        m_trackToLayer.insert(track, casted);
        _logger().info("Registered layer for track", { kv("track", track) });
    } else {
        _logger().warn("Invalid layer provided for track registration", { kv("track", track) });
    }
}

void TrackManager::unregisterLayer(const QString &track)
{
    m_trackToLayer.remove(track);
}

void TrackManager::activate(const QString &track, int zoomLevel)
{
    if (!m_http) return;

    m_http->post(ApiEndpoints::TrackSenderStart(track), QVariantMap{{ "zoomLevel", zoomLevel }}, [this, track](QRestReply& reply) {
        if (!reply.isSuccess()) {
            _logger().warn("Failed to activate track", {
                kv("track", track),
                kv("error", reply.errorString()),
                kv("response", reply.readText())
            });
            return;
        }
        if (m_trackToLayer.contains(track)) {
            m_trackToLayer.value(track)->setActive(true);
            _logger().info("Activated track", { kv("track", track) });
            emit activated(track);
        }
    });
}

void TrackManager::activateHistory(const QString &topic, const QString &track_iridess_uidd)
{
    if (!m_http) return;

    m_http->post(ApiEndpoints::TrackHistorySenderStart(topic, track_iridess_uidd), QByteArray{}, [this, topic, track_iridess_uidd](const QRestReply& reply) {
        if (!reply.isSuccess()) {
            _logger().warn("Failed to activate track history", {
                kv("topic", topic),
                kv("trackUid", track_iridess_uidd),
                kv("error", reply.errorString())
            });
            const QString k = key(topic, track_iridess_uidd);
            m_histState.insert(k, Inactive);
            emit historyStateChanged(topic, track_iridess_uidd, Inactive);
            return;
        }
        _logger().info("Track history activation accepted, awaiting payload", {
            kv("topic", topic),
            kv("trackUid", track_iridess_uidd)
        });
        emit activatedHistory(topic, track_iridess_uidd);
    });
}

void TrackManager::deactivate(const QString &track)
{
    if (!m_http) return;

    m_http->post(ApiEndpoints::TrackSenderStop(track), QByteArray{}, [this, track](const QRestReply& reply) {
        if (!reply.isSuccess()) {
            _logger().warn("Failed to deactivate track", {
                kv("track", track),
                kv("error", reply.errorString())
            });
            return;
        }
        if (m_trackToLayer.contains(track)) {
            m_trackToLayer.value(track)->setActive(false);
            _logger().info("Deactivated track", { kv("track", track) });
            emit deactivated(track);
        }
    });
}

void TrackManager::deactivateHistory(const QString &topic, const QString &track_iridess_uid)
{
    if (!m_http) return;

    m_http->post(ApiEndpoints::TrackHistorySenderStop(topic, track_iridess_uid), QByteArray{}, [this, topic, track_iridess_uid](const QRestReply& reply) {
        if (!reply.isSuccess()) {
            _logger().warn("Failed to deactivate track history", {
                kv("topic", topic),
                kv("trackUid", track_iridess_uid),
                kv("error", reply.errorString())
            });
            return;
        }
        
        _logger().info("Deactivated track history", {
            kv("topic", topic),
            kv("trackUid", track_iridess_uid)
        });

        emit deactivatedHistory(topic, track_iridess_uid);
        const QString k = key(topic, track_iridess_uid);
        m_histState.insert(k, Inactive);
        emit historyStateChanged(topic, track_iridess_uid, Inactive);
        emit requestClearHistory(topic, track_iridess_uid);
    });
}

void TrackManager::deactivateAll()
{
    if (!m_http) return;

    _logger().info("Deactivating all tracks");

    RetryPolicy policy;
    policy.maxAttempts = 3;
    m_http->post(ApiEndpoints::TrackSenderStopAll(), QByteArray{}, [this](QRestReply& reply) {
        if (!reply.isSuccess()) {
            _logger().warn("Failed to deactivate all tracks", {
                kv("error", reply.errorString())
            });
            emit deactivateAllFailed();
            return;
        }

        for (auto it = m_trackToLayer.begin(); it != m_trackToLayer.end(); it++) {
            const QString &name = it.key();
            BaseTrackMapLayer* layer = it.value();

            if (layer->active()) {
                layer->setActive(false);
                _logger().info("Deactivated track", {
                    kv("track", name)
                });
            }
        }

        _logger().info("Deactivated all tracks");
        emit deactivateAllFinished();
    }, policy);
}

void TrackManager::syncZoomLevel(int zoomLevel)
{
    m_zoomSyncDebouncer.trigger([this, zoomLevel] {
        for (auto it = m_trackToLayer.begin(); it != m_trackToLayer.end(); it++) {
            const QString &name = it.key();
            const BaseTrackMapLayer* layer = it.value();

            if (layer->active()) {
                activate(name, zoomLevel);
                _logger().info("Synced layer", {
                    kv("track", name),
                    kv("zoomLevel", zoomLevel)
                });
            }
        }
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
        _logger().info("History payload arrived, state promoted to active", {
            kv("topic", topic),
            kv("trackUid", uid)
        });
        emit historyStateChanged(topic, uid, Active);
    }
}
