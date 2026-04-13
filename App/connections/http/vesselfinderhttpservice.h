#ifndef VESSELFINDERHTTPSERVICE_H
#define VESSELFINDERHTTPSERVICE_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QQmlEngine>
#include <QPointer>

#include "entities/Track.h"
#include "entities/ClusteredPayload.h"
#include "entities/Vessel.h"
#include "layers/BaseTrackMapLayer.h"
#include "layers/BaseTrackMapLayer.h"
#include "interfaces/IMessageParser.h"
#include "httpvesselfindertrackspoller.h"

class VesselFinderHttpService : public QObject
{
    Q_OBJECT
    QML_SINGLETON
    QML_ELEMENT

    Q_PROPERTY(bool running READ isRunning NOTIFY runningChanged)


public:
    explicit VesselFinderHttpService(QObject* parent = nullptr);

    using VesselPayload = ClusteredPayload<Vessel>;

    void initialize(const QString& endpointUrl, int pollMs = 2000);

    Q_INVOKABLE void registerLayer(const QString& name, QObject* layer);
    Q_INVOKABLE void registerParser(IMessageParser<VesselPayload>* parser);

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
    void clearLayerData();
    void setClusterSimulatorRunning(bool running);

    HttpVesselFinderTracksPoller* poller_ = nullptr;
    IMessageParser<VesselPayload>* parser_ = nullptr;
    QPointer<BaseTrackMapLayer> targetLayer_;
    QNetworkAccessManager m_networkManager;

    bool running_ = false;
};

#endif // VESSELFINDERHTTPSERVICE_H
