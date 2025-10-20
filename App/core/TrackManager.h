#ifndef TRACKMANAGER_H
#define TRACKMANAGER_H

#include <QObject>
#include <QQmlEngine>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <layers/BaseTrackMapLayer.h>

class TrackManager : public  QObject
{
    Q_OBJECT
    QML_SINGLETON
    QML_ELEMENT

public:
    explicit TrackManager(QObject* parent = nullptr);

    Q_INVOKABLE void registerLayer(const QString& track, QObject* layer);

    Q_INVOKABLE void unregisterLayer(const QString& track);

    Q_INVOKABLE void activate(const QString& topic);
    Q_INVOKABLE void activateHistory(const QString& topic, const QString& track_iridess_uid);

    Q_INVOKABLE void deactivate(const QString& track);
    Q_INVOKABLE void deactivateHistory(const QString& topic, const QString& track_iridess_uid);

    Q_INVOKABLE void deactivateSync(const QString& track);

    Q_INVOKABLE BaseTrackMapLayer* getLayer(const QString& track);


signals:
    void activated(const QString& track);
    void deactivated(const QString& track);
    void activatedHistory(const QString& topic, const QString& track_iridess_uid);
    void deactivatedHistory(const QString& topic, const QString& track_iridess_uid);

private:
    QHash<QString, BaseTrackMapLayer*> m_trackToLayer;
    QNetworkAccessManager m_networkManager;
};

#endif // TRACKMANAGER_H
