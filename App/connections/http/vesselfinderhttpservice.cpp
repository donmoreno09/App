#include "./vesselfinderhttpservice.h"

#include <QMetaObject>
#include <QNetworkReply>
#include <QNetworkRequest>

#include "AppLogger.h"
#include "connections/ApiEndpoints.h"
#include "layers/VesselMapLayer.h"

// Anonymous namespace to make _logger exclusive for this file
namespace {
Logger& _logger()
{
    static Logger logger = AppLogger::get().child({
        {"service", "VF-HTTP"}
    });
    return logger;
}
}

VesselFinderHttpService::VesselFinderHttpService(QObject* parent)
    : QObject(parent)
{
}

void VesselFinderHttpService::initialize(const QString& endpointUrl, int pollMs)
{
    if (poller_) {
        _logger().warn("initialize() called twice");
        return;
    }

    _logger().info("Initializing", { kv("endpoint", endpointUrl) });
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
        _logger().warn("Invalid layer registered");
        return;
    }

    targetLayer_ = casted;
    _logger().info("Layer registered: " + targetLayer_.data()->layerName());
}

void VesselFinderHttpService::registerParser(IMessageParser<VesselPayload>* parser)
{
    parser_ = parser;
    _logger().info("Parser registered");
}

void VesselFinderHttpService::start()
{
    if (!poller_ || running_) {
        return;
    }

    if (!targetLayer_) {
        _logger().warn("start() but no layer registered");
        return;
    }

    running_ = true;
    targetLayer_->setActive(true);
    poller_->start();
    setClusterSimulatorRunning(true);
    emit runningChanged(true);

    _logger().info("Polling started");
}

void VesselFinderHttpService::stop()
{
    if (!poller_ || !running_) {
        return;
    }

    running_ = false;
    targetLayer_->setActive(false);
    poller_->stop();
    setClusterSimulatorRunning(false);

    emit runningChanged(false);

    _logger().info("Polling stopped");
}

bool VesselFinderHttpService::isRunning() const
{
    return running_;
}

void VesselFinderHttpService::onHttpData(const QByteArray& data)
{
    if (!running_) {
        _logger().info("data received while stopped -> ignored");
        return;
    }

    if (!parser_ || !targetLayer_) {
        return;
    }

    auto* vesselLayer = qobject_cast<VesselMapLayer*>(targetLayer_.data());
    if (!vesselLayer) {
        _logger().warn("Target layer is not VesselMapLayer");
        return;
    }

    const VesselPayload payload = parser_->parse(data);

    auto* vesselModel = vesselLayer->vesselModel();
    auto* clusterModel = vesselLayer->clusterModel();
    if (!vesselModel || !clusterModel)
        return;

    QMetaObject::invokeMethod(
        vesselLayer,
        [vesselModel, clusterModel, payload]() {
            if (payload.hasTracks) {
                vesselModel->upsert(payload.tracks);
            }

            if (payload.hasClusters) {
                clusterModel->upsert(payload.clusters);
            }
        },
        Qt::QueuedConnection
        );
}

void VesselFinderHttpService::onError(const QString& err)
{
    emit pollingError(err);
    _logger().warn("Poll error: " + err, { kv("error", err) });
}

void VesselFinderHttpService::clearLayerData()
{
    if (!targetLayer_) {
        _logger().info("clearLayerData(): layer destroyed, skipping");
        return;
    }

    auto* vesselLayer = qobject_cast<VesselMapLayer*>(targetLayer_.data());
    if (!vesselLayer)
        return;

    auto* vesselModel = vesselLayer->vesselModel();
    auto* clusterModel = vesselLayer->clusterModel();

    QMetaObject::invokeMethod(
        vesselLayer,
        [vesselModel, clusterModel]() {
            if (vesselModel)
                vesselModel->clear();
            if (clusterModel)
                clusterModel->clear();
        },
        Qt::QueuedConnection
        );
}

void VesselFinderHttpService::setClusterSimulatorRunning(bool running)
{
    const QUrl url(running ? ApiEndpoints::ClustersStart()
                           : ApiEndpoints::ClustersStop());

    QNetworkReply* reply = m_networkManager.post(QNetworkRequest(url), QByteArray{});
    connect(reply, &QNetworkReply::finished, this, [reply, running, url]() {
        if (reply->error() != QNetworkReply::NoError) {
            _logger().warn(QString("Cluster simulator %1 failed: %2").arg(running ? "start" : "stop").arg(reply->errorString()), {
                kv("url", url),
                kv("error", reply->errorString())
            });
        } else {
            _logger().warn(QString("Cluster simulator %1").arg(running ? "start" : "stop"), { kv("url", url) });
        }

        reply->deleteLater();
    });
}
