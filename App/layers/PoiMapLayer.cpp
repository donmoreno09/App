#include "PoiMapLayer.h"
#include "../persistence/poipersistencemanager.h"
#include <QDebug>
#include <core/GeoSelectionUtils.h>
#include <entities/Poi.h>

PoiMapLayer::PoiMapLayer(QObject* parent)
    : BaseMapLayer(parent)
{
    setObjectName("PoiMapLayer");
    m_poiModel = new VariantListModel(this);
}

void PoiMapLayer::initialize() {
    qDebug() << "[PoiMapLayer:initialize] polling ...";
    BaseMapLayer::initialize();
    loadData();
}

void PoiMapLayer::selectInRect(const QGeoCoordinate &topLeft, const QGeoCoordinate &bottomRight)
{
    QVariantList selectedPois = GeoSelection::selectInRect(m_poiModel->data(), topLeft, bottomRight);
    qDebug() << "[PoiMapLayer] selectedPois: " << selectedPois;
    m_selectedPois = selectedPois;
    emit selectedInRect();
}

void PoiMapLayer::clearSelection()
{
    m_selectedPois.clear();
    emit clearedSelection();
}

void PoiMapLayer::loadData()
{
    if (!m_loader) {
        m_loader = new PoiPersistenceManager(this);
        connect(m_loader, &IPersistenceManager::objectsLoaded, this, [this](const QList<IPersistable*>& objs) {
            this->handleLoadedObjects(objs);
        });
    }

    m_loader->load();
}

void PoiMapLayer::handleLoadedObjects(const QList<IPersistable*>& objects)
{
    QVariantList pois;

    for (IPersistable* obj : objects) {
        Poi* poi = dynamic_cast<Poi*>(obj);
        if (poi) {
            QVariantMap map;
            map["id"] = poi->id;
            map["label"] = poi->label;
            map["typeName"] = poi->typeName;
            map["typeId"] = poi->typeId;
            map["categoryName"] = poi->categoryName;
            map["categoryId"] = poi->categoryId;
            map["healthStatusName"] = poi->healthStatusName;
            map["healthStatusId"] = poi->healthStatusId;
            map["operationalStateName"] = poi->operationalStateName;
            map["operationalStateId"] = poi->operationalStateId;
            map["layerName"] = poi->layerName;
            map["layerId"] = poi->layerId;
            map["geometry"] = poi->geometry.toJson();
            map["details"] = poi->details.toJson();
            pois.append(map);
        }
    }

    m_poiModel->resetWith(pois);
    emit poisChanged();
}

VariantListModel *PoiMapLayer::poiModel() const
{
    return m_poiModel;
}
