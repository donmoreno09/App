#ifndef VESSELFINDERHTTPSERVICE_H
#define VESSELFINDERHTTPSERVICE_H

#include <QObject>
#include <QQmlEngine>
#include <QPointer>
#include <entities/Track.h>
#include <layers/BaseTrackMapLayer.h>

#include "./httpvesselfindertrackspoller.h"
#include "interfaces/IMessageParser.h"

class VesselFinderHttpService : public QObject
{
    Q_OBJECT
    QML_SINGLETON
    QML_ELEMENT

    Q_PROPERTY(bool running READ isRunning NOTIFY runningChanged)


public:
    explicit VesselFinderHttpService(QObject* parent = nullptr);

    void initialize(const QString& endpointUrl, int pollMs = 2000);

    Q_INVOKABLE void registerLayer(const QString& name, QObject* layer);
    Q_INVOKABLE void registerParser(IMessageParser<Track>* parser);

    Q_INVOKABLE void start();
    Q_INVOKABLE void stop();
    bool isRunning() const;

signals:
    void pollingError(const QString& error);
    void runningChanged(bool running);

private slots:
    void onHttpData(const QByteArray& data);
    void onError(const QString& err);

private:
    void clearTracks();

    HttpVesselFinderTracksPoller* poller_ = nullptr;
    IMessageParser<Track>* parser_ = nullptr;
    QPointer<BaseTrackMapLayer> targetLayer_;

    bool running_ = false;
};

#endif // VESSELFINDERHTTPSERVICE_H
