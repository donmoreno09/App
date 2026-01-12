#include "AlertZoneMapLayerController.h"
#include <QDebug>
#include <core/GeoSelectionUtils.h>
#include <entities/AlertZone.h>
#include <QQmlEngine>

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
}

void AlertZoneMapLayerController::selectInRect(const QGeoCoordinate &topLeft, const QGeoCoordinate &bottomRight)
{
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
    qDebug() << "[AlertZoneMapLayerController] selectedAlertZones: " << selectedAlertZones;
    m_selectedAlertZones = selectedAlertZones;
    emit selectedInRect();
}

void AlertZoneMapLayerController::clearSelection()
{
    m_selectedAlertZones.clear();
    emit clearedSelection();
}

AlertZoneModel *AlertZoneMapLayerController::alertZoneModel() const
{
    return m_alertZoneModel;
}
