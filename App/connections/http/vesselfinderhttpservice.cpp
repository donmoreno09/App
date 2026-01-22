#include "./vesselfinderhttpservice.h"
#include <QDebug>
#include <QMetaObject>
#include <layers/TrackMapLayer.h>

VesselFinderHttpService::VesselFinderHttpService(QObject* parent)
    : QObject(parent)
{
}

void VesselFinderHttpService::initialize(const QString& endpointUrl, int pollMs)
{
    if (poller_) {
        qWarning() << "[VF-HTTP] initialize() called twice";
        return;
    }

    poller_ = new HttpVesselFinderTracksPoller(endpointUrl, pollMs, this);

    connect(poller_, &HttpVesselFinderTracksPoller::dataReceived,
            this, &VesselFinderHttpService::onHttpData);

    connect(poller_, &HttpVesselFinderTracksPoller::requestError,
            this, &VesselFinderHttpService::onError);
}

void VesselFinderHttpService::registerLayer(const QString& name, QObject* layer)
{
    Q_UNUSED(name)

    auto* casted = qobject_cast<BaseTrackMapLayer*>(layer);
    if (!casted) {
        qWarning() << "[VF-HTTP] Invalid layer registered";
        return;
    }

    targetLayer_ = casted;
    qDebug() << "[VF-HTTP] Layer registered:" << targetLayer_.data();
}

void VesselFinderHttpService::registerParser(IMessageParser<Track>* parser)
{
    parser_ = parser;
    qDebug() << "[VF-HTTP] Parser registered";
}

void VesselFinderHttpService::start()
{
    if (!poller_ || running_) {
        return;
    }

    if (!targetLayer_) {
        qWarning() << "[VF-HTTP] start() but no layer registered";
        return;
    }

    running_ = true;
    poller_->start();
    emit runningChanged(true);

    qDebug() << "[VF-HTTP] Polling started";
}

void VesselFinderHttpService::stop()
{
    if (!poller_ || !running_) {
        return;
    }

    running_ = false;
    poller_->stop();
    clearTracks();   // deferred

    emit runningChanged(false);

    qDebug() << "[VF-HTTP] Polling stopped";
}

bool VesselFinderHttpService::isRunning() const
{
    return running_;
}

void VesselFinderHttpService::onHttpData(const QByteArray& data)
{
    if (!running_) {
        qDebug() << "[VF-HTTP] data received while stopped -> ignored";
        return;
    }

    if (!parser_ || !targetLayer_) {
        return;
    }

    auto* trackLayer = qobject_cast<TrackMapLayer*>(targetLayer_.data());
    if (!trackLayer) {
        qWarning() << "[VF-HTTP] Target layer is not TrackMapLayer";
        return;
    }

    QVector<Track> tracks = parser_->parse(data);

    auto* model = trackLayer->trackModel();
    if (!model)
        return;

    QMetaObject::invokeMethod(
        model,
        [model, tracks]() {
            model->upsert(tracks);
        },
        Qt::QueuedConnection
    );
}

void VesselFinderHttpService::onError(const QString& err)
{
    emit pollingError(err);
    qWarning() << "[VF-HTTP] Poll error:" << err;
}

void VesselFinderHttpService::clearTracks()
{
    if (!targetLayer_) {
        qDebug() << "[VF-HTTP] clearTracks(): layer destroyed, skipping";
        return;
    }

    auto* trackLayer = qobject_cast<TrackMapLayer*>(targetLayer_.data());
    if (!trackLayer)
        return;

    auto* model = trackLayer->trackModel();

    QMetaObject::invokeMethod(
        model,
        [model]() {
            model->clear();
        },
        Qt::QueuedConnection
    );
}
