#include "AlertZoneMapLayerController.h"

#include <QQmlEngine>

#include "AppLogger.h"
#include "core/GeoSelectionUtils.h"
#include "entities/AlertZone.h"

// Anonymous namespace to make _logger exclusive for this file
namespace {
Logger& _logger()
{
    static Logger logger = AppLogger::get().child({
        {"service", "ALERT-ZONE-MAP-LAYER-CONTROLLER"}
    });
    return logger;
}
}

AlertZoneMapLayerController::AlertZoneMapLayerController(QObject* parent)
    : BaseMapLayer(parent)
{
    setObjectName("AlertZoneMapLayerController");
}

QVariantList AlertZoneMapLayerController::selectedObjects() const
{
    return m_selectedAlertZones;
}

void AlertZoneMapLayerController::initialize()
{
    auto* engine = qmlEngine(this);
    m_alertZoneModel = engine->singletonInstance<AlertZoneModel*>("App", "AlertZoneModel");

    if (!m_alertZoneModel) {
        _logger().warn("Failed to initialize AlertZoneModel");
        return;
    }

    _logger().info("AlertZoneMapLayerController initialized");
}

void AlertZoneMapLayerController::selectInRect(const QGeoCoordinate &topLeft, const QGeoCoordinate &bottomRight)
{
    if (!m_alertZoneModel) {
        _logger().warn("Cannot select alert zones: model is not initialized");
        return;
    }

    QVariantList alertZonesList;
    const auto& alertZones = m_alertZoneModel->alertZones();

    for (auto it = alertZones.cbegin(); it != alertZones.cend(); it++) {
        QVariantMap alertZone;

        QVariantMap geometry;
        geometry["shapeTypeId"] = it->geometry.shapeTypeId;

        // For now, just add a basic coordinate (center of first point)
        if (!it->geometry.coordinates.isEmpty()) {
            QVariantMap coordinate;
            coordinate["x"] = it->geometry.coordinates[0].x();
            coordinate["y"] = it->geometry.coordinates[0].y();
            geometry["coordinate"] = coordinate;
        }

        alertZone["geometry"] = geometry;
        alertZonesList.append(alertZone);
    }

    QVariantList selectedAlertZones = GeoSelection::selectInRect(alertZonesList, topLeft, bottomRight);
    m_selectedAlertZones = selectedAlertZones;

    _logger().info("Alert zones selected in rectangle", {
        kv("selectedCount", selectedAlertZones.size())
    });

    emit selectedInRect();
}

void AlertZoneMapLayerController::clearSelection()
{
    m_selectedAlertZones.clear();
    _logger().info("Cleared alert zone selection");
    emit clearedSelection();
}

AlertZoneModel *AlertZoneMapLayerController::alertZoneModel() const
{
    return m_alertZoneModel;
}
