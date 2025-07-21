#include "staticpoimaplayer.h"
#include "../events/selectionboxbus.h"
#include "../core/geoselectionutils.h"
#include "../persistence/poipersistencemanager.h"
#include "../models/poi.h"
#include <QDebug>

StaticPoiMapLayer::StaticPoiMapLayer(QObject* parent)
    : BaseMapLayer(parent)
{
    setObjectName("StaticPoiMapLayer");
    m_poiModel = new VariantListModel(this);

    connect(SelectionBoxBus::instance(), &SelectionBoxBus::selected, this, &StaticPoiMapLayer::handleSelectionBoxSelected);
    connect(SelectionBoxBus::instance(), &SelectionBoxBus::deselected, this, &StaticPoiMapLayer::handleSelectionBoxDeselected);
}

void StaticPoiMapLayer::initialize() {
    qDebug() << "[StaticPoiMapLayer:initialize] polling ...";
    BaseMapLayer::initialize();
    loadData();
}

void StaticPoiMapLayer::syncSelectedObject(const QVariant &object, bool isToRemove)
{
    for (int i = 0; i < m_selectedPois.length(); i++) {
        if (m_selectedPois[i].toMap().value("id") == object.toMap().value("id")) {
            if (isToRemove) m_selectedPois.removeAt(i);
            else m_selectedPois[i] = object;
            break;
        }
    }

    emit selectedObjectsChanged();
}

void StaticPoiMapLayer::handleSelectionBoxSelected(const QString &target, const QGeoCoordinate &topLeft, const QGeoCoordinate &bottomRight, int mode)
{
    if (target != layerName())
        return;

    QVariantList selectedPois = GeoSelection::selectInRect(m_poiModel->data(), topLeft, bottomRight);
    qDebug() << "[StaticPoiMapLayer] selectedPois: " << selectedPois;
    m_selectedPois = selectedPois;
    emit selectedObjectsChanged();
}

void StaticPoiMapLayer::handleSelectionBoxDeselected(const QString &target, int mode)
{
    if (target != layerName())
        return;

    m_selectedPois.clear();
    emit selectedObjectsChanged();
}

void StaticPoiMapLayer::loadData()
{
    if (!m_loader) {
        m_loader = new PoiPersistenceManager(this);
        connect(m_loader, &IPersistenceManager::objectsLoaded, this, [this](const QList<IPersistable*>& objs) {
            this->handleLoadedObjects(objs);
        });
    }

    m_loader->load();
}

void StaticPoiMapLayer::handleLoadedObjects(const QList<IPersistable*>& objects)
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

VariantListModel *StaticPoiMapLayer::poiModel() const
{
    return m_poiModel;
}
