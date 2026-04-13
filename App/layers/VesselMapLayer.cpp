#include "VesselMapLayer.h"

#include "AppLogger.h"
#include "core/GeoSelectionUtils.h"
#include "core/TrackManager.h"

// Anonymous namespace to make _logger exclusive for this file
namespace {
Logger& _logger()
{
    static Logger logger = AppLogger::get().child({
        {"service", "VESSEL-FINDER-MAP-LAYER"}
    });
    return logger;
}
}

VesselMapLayer::VesselMapLayer(QObject* parent)
    : BaseTrackMapLayer(parent)
{
    setObjectName("VesselMapLayer");
    m_vesselModel = new VesselModel(this);

    if (auto* tm = TrackManager::instance()) {
        QObject::connect(m_vesselModel, &VesselModel::historyPayloadArrived,
                         tm, &TrackManager::onHistoryPayloadArrived);
    } else {
        _logger().warn("TrackManager singleton not yet constructed.");
    }

    m_clearVesselsTimer = new QTimer(this);
    m_clearVesselsTimer->setSingleShot(true);
    m_clearVesselsTimer->setInterval(60 * 1000);

    connect(m_clearVesselsTimer, &QTimer::timeout, this, [this]() {
        if (!m_vesselModel->vessels().isEmpty() || clusterModel()->rowCount() > 0) {
            _logger().info("Timeout: clearing vessels and clusters due to inactivity.");
            m_vesselModel->clear();
            clusterModel()->clear();
        }
    });
}

void VesselMapLayer::selectInRect(const QGeoCoordinate &topLeft, const QGeoCoordinate &bottomRight)
{
    QVariantList geoVessels;
    const auto& vessels = m_vesselModel->vessels();

    for (auto it = vessels.cbegin(); it != vessels.cend(); it++) {
        QVariantMap editableVessel;

        QVariantMap coordinate;
        coordinate["x"] = it->pos.longitude();
        coordinate["y"] = it->pos.latitude();

        QVariantMap geometry;
        geometry["shapeTypeId"] = static_cast<int>(GeoSelection::ShapeType::Point);
        geometry["coordinate"]  = coordinate;

        editableVessel["geometry"] = geometry;
        geoVessels.append(editableVessel);
    }

    m_selectedVessels = GeoSelection::selectInRect(geoVessels, topLeft, bottomRight);
    emit selectedInRect();
}

void VesselMapLayer::clearSelection()
{
    m_selectedVessels.clear();
    emit clearedSelection();
}

VesselModel *VesselMapLayer::vesselModel() const
{
    return m_vesselModel;
}
