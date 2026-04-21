#include "TirMapLayer.h"

#include "AppLogger.h"
#include "core/GeoSelectionUtils.h"
#include "core/TrackManager.h"

// Anonymous namespace to make _logger exclusive for this file
namespace {
Logger& _logger()
{
    static Logger logger = AppLogger::get().child({
        {"service", "TIR-MAP-LAYER"}
    });
    return logger;
}
}

TirMapLayer::TirMapLayer(QObject* parent)
    : BaseTrackMapLayer(parent)
{
    setObjectName("TirMapLayer");
    m_tirModel = new TirModel(this);

    if (auto* tm = TrackManager::instance()) {
        QObject::connect(m_tirModel, &TirModel::historyPayloadArrived,
                         tm, &TrackManager::onHistoryPayloadArrived);
        QObject::connect(tm, &TrackManager::requestClearHistory,
                         m_tirModel, [this](const QString& /*topic*/, const QString& uid) {
                             m_tirModel->clearHistory(uid);
                         });
    } else {
        _logger().warn("TrackManager singleton not yet constructed.");
    }

    m_clearTirsTimer = new QTimer(this);
    m_clearTirsTimer->setSingleShot(true);
    m_clearTirsTimer->setInterval(60 * 1000); // 60 seconds

    connect(m_clearTirsTimer, &QTimer::timeout, this, [this]() {
        if (!m_tirModel->tirs().isEmpty() || clusterModel()->rowCount() > 0) {
            _logger().info("Timeout: clearing tirs and clusters due to inactivity");
            m_tirModel->clear();
            clusterModel()->clear();
        }
    });
}

void TirMapLayer::selectInRect(const QGeoCoordinate &topLeft, const QGeoCoordinate &bottomRight)
{
    // In order for selection to work, I'll mutate the tirs
    // for now to include geometry with the coordinate property so
    // that it'll conform to GeoSelection::selectInRect()'s selection logic.
    QVariantList geoTirs;
    const auto& tirs = m_tirModel->tirs();
    for (auto it = tirs.cbegin(); it != tirs.cend(); it++) {
        QVariantMap editableTir;

        QVariantMap coordinate;
        coordinate["x"] = it->pos.longitude();
        coordinate["y"] = it->pos.latitude();

        QVariantMap geometry;
        geometry["shapeTypeId"] = static_cast<int>(GeoSelection::ShapeType::Point);
        geometry["coordinate"] = coordinate;

        editableTir["geometry"] = geometry;
        geoTirs.append(editableTir);
    }

    QVariantList selectedTirs = GeoSelection::selectInRect(geoTirs, topLeft, bottomRight);
    _logger().info("selectedTirs", { kv("selectedTirs", selectedTirs) });
    m_selectedTirs = selectedTirs;
    emit selectedInRect();
}

void TirMapLayer::clearSelection()
{
    m_selectedTirs.clear();
    emit clearedSelection();
}

TirModel *TirMapLayer::tirModel() const
{
    return m_tirModel;
}

