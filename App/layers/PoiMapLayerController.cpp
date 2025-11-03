#include "PoiMapLayerController.h"
#include <QDebug>
#include <core/GeoSelectionUtils.h>
#include <entities/Poi.h>
#include <QQmlEngine>

PoiMapLayerController::PoiMapLayerController(QObject* parent)
    : BaseMapLayer(parent)
{
    setObjectName("PoiMapLayerController");
}

QVariantList PoiMapLayerController::selectedObjects() const
{
    return m_selectedPois;
}

void PoiMapLayerController::initialize()
{
    auto* engine = qmlEngine(this);
    m_poiModel = engine->singletonInstance<PoiModel*>("App", "PoiModel");
}

void PoiMapLayerController::selectInRect(const QGeoCoordinate &topLeft, const QGeoCoordinate &bottomRight)
{
    QVariantList poisList;
    const auto& pois = m_poiModel->pois();
    for (auto it = pois.cbegin(); it != pois.cend(); it++) {
        QVariantMap poi;

        QVariantMap coordinate;
        coordinate["x"] = it->geometry.coordinate.x();
        coordinate["y"] = it->geometry.coordinate.y();

        QVariantMap geometry;
        geometry["shapeTypeId"] = it->geometry.shapeTypeId;
        geometry["coordinate"] = coordinate;
        if (it->geometry.shapeTypeId != static_cast<int>(GeoSelection::ShapeType::Point)) {
            qDebug() << "[WARNING] Selection other than coordinate is yet to be implemented! Change GeoSelection to use Geometry class instead of QVariant.";
        }

        poi["geometry"] = geometry;
        poisList.append(poi);
    }
    QVariantList selectedPois = GeoSelection::selectInRect(poisList, topLeft, bottomRight);
    qDebug() << "[PoiMapLayerController] selectedPois: " << selectedPois;
    m_selectedPois = selectedPois;
    emit selectedInRect();
}

void PoiMapLayerController::clearSelection()
{
    m_selectedPois.clear();
    emit clearedSelection();
}

PoiModel *PoiMapLayerController::poiModel() const
{
    return m_poiModel;
}
