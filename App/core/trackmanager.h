#ifndef TRACKMANAGER_H
#define TRACKMANAGER_H

#include <QObject>
#include <QQmlEngine>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include "../layers/trackmaplayer.h"

class TrackManager : public  QObject
{
    Q_OBJECT

public:
    static TrackManager *instance();

    static QObject *singletonProvider(QQmlEngine*, QJSEngine*);

    Q_INVOKABLE void registerLayer(const QString& track, QObject* layer);

    Q_INVOKABLE void unregisterLayer(const QString& track);

    Q_INVOKABLE void activate(const QString& track);

    Q_INVOKABLE void deactivate(const QString& track);
    Q_INVOKABLE void deactivateSync(const QString& track);


signals:
    void activated(const QString& track);
    void deactivated(const QString& track);

private:
    explicit TrackManager(QObject* parent = nullptr);

    QHash<QString, TrackMapLayer*> m_trackToLayer;
    QNetworkAccessManager m_networkManager;
};

#endif // TRACKMANAGER_H
