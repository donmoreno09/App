#include "QEventLoop"
#include "trackmanager.h"
#include "../connections/apiendpoints.h"

TrackManager::TrackManager(QObject* parent) : QObject(parent) {}

TrackManager *TrackManager::instance()
{
    static TrackManager *manager = new TrackManager();
    return manager;
}

QObject *TrackManager::singletonProvider(QQmlEngine *, QJSEngine *)
{
    return instance();
}

void TrackManager::registerLayer(const QString &track, QObject *layer)
{
    auto* casted = qobject_cast<TrackMapLayer*>(layer);
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
            emit m_trackToLayer.value(track)->activated();
            emit activated(track);
        }
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
            emit m_trackToLayer.value(track)->deactivated();
            emit deactivated(track);
        }
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
            emit m_trackToLayer.value(track)->deactivated();
            emit deactivated(track);
        }
    }

    reply->deleteLater();
}
