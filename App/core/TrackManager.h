#ifndef TRACKMANAGER_H
#define TRACKMANAGER_H

#include <QObject>
#include <QQmlEngine>
#include <QHash>
#include <layers/BaseTrackMapLayer.h>
#include "Networking/HttpClient.h"

class TrackManager : public  QObject
{
    Q_OBJECT
    QML_SINGLETON
    QML_ELEMENT

public:
    explicit TrackManager(QObject* parent = nullptr);
    static TrackManager* instance();

    void initialize(HttpClient* http);

    Q_INVOKABLE void registerLayer(const QString& track, QObject* layer);

    Q_INVOKABLE void unregisterLayer(const QString& track);

    Q_INVOKABLE void activate(const QString& topic);
    Q_INVOKABLE void activateHistory(const QString& topic, const QString& track_iridess_uid);

    Q_INVOKABLE void deactivate(const QString& track);
    Q_INVOKABLE void deactivateHistory(const QString& topic, const QString& track_iridess_uid);

    Q_INVOKABLE BaseTrackMapLayer* getLayer(const QString& track);

    enum HistoryState { Inactive = 0, Loading = 1, Active = 2 };
    Q_ENUM(HistoryState)

    Q_INVOKABLE void setHistoryActive(const QString& topic, const QString& uid, bool on);
    Q_INVOKABLE int  historyState(const QString& topic, const QString& uid) const;
    Q_INVOKABLE bool isHistoryActive(const QString& topic, const QString& uid) const {
        return historyState(topic, uid) == Active;
    }

public slots:
    void onHistoryPayloadArrived(const QString& topic, const QString& uid);
signals:
    void activated(const QString& track);
    void deactivated(const QString& track);
    void activatedHistory(const QString& topic, const QString& track_iridess_uid);
    void deactivatedHistory(const QString& topic, const QString& track_iridess_uid);

    void historyStateChanged(const QString& topic, const QString& uid, int state);
    void requestClearHistory(const QString& topic, const QString& uid);

private:
    HttpClient* m_http = nullptr;
    QHash<QString, BaseTrackMapLayer*> m_trackToLayer;
    QHash<QString, HistoryState> m_histState;

    static TrackManager* s_instance;

    inline QString key(const QString& topic, const QString& uid) const {
        // Using a delimiter unlikely to appear in topic/uid
        return topic + QLatin1Char('|') + uid;
    }
};

#endif // TRACKMANAGER_H
