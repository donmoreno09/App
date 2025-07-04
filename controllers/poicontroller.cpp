#include "poicontroller.h"
#include "../models/poi.h"

PoiController::PoiController(QObject *parent)
    : QObject(parent)
{
    connect(&m_persistenceManager, &IPersistenceManager::objectSaved, this, [=](bool success, const QString &objectId) {
        if (success)
            emit poiSavedSuccessfully(objectId);
        else
            emit poiSaveFailed();
    });

    connect(&m_persistenceManager, &IPersistenceManager::objectUpdated, this, [=](bool success) {
        if (success)
            emit poiUpdatedSuccessfully();
        else
            emit poiUpdateFailed();
    });

    connect(&m_persistenceManager, &IPersistenceManager::objectRemoved, this, [=](bool success) {
        if (success)
            emit poiDeletedSuccessfully();
        else
            emit poiDeleteFailed();
    });

    connect(&m_persistenceManager, &IPersistenceManager::objectGot, this, [=](const IPersistable *obj) {
        if (obj) {
            const Poi* poi = dynamic_cast<const Poi*>(obj);
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
                emit poiFetchedSuccessfully(map);
                return;
            }
        }

        emit poiFetchFailed();
    });
}

void PoiController::getPoi(const QString &id)
{
    m_persistenceManager.get(id);
}

void PoiController::savePoiFromQml(const QVariantMap &data)
{
    Poi poi;

    poi.label = data.value("label").toString();
    poi.layerId = data.value("layerId").toInt();
    poi.typeId = data.value("typeId").toInt();
    poi.categoryId = data.value("categoryId").toInt();
    poi.healthStatusId = data.value("healthStatusId").toInt();
    poi.operationalStateId = data.value("operationalStateId").toInt();

    // Geometry
    QVariantMap geomMap = data.value("geometry").toMap();
    Geometry geom;
    geom.shapeTypeId = geomMap.value("shapeTypeId").toInt();
    geom.surface = geomMap.value("surface").toDouble();
    geom.height = geomMap.value("height").toDouble();

    QVariantMap centerCoordMap = geomMap.value("coordinate").toMap();
    geom.coordinate.setX(centerCoordMap.value("x").toDouble());
    geom.coordinate.setY(centerCoordMap.value("y").toDouble());

    geom.radiusA = geomMap.value("radiusA").toDouble();
    geom.radiusB = geomMap.value("radiusB").toDouble();

    QVariantList coordList = geomMap.value("coordinates").toList();
    QList<QVector2D> coords;
    for (const QVariant &coordVar : coordList) {
        QVariantMap coordMap = coordVar.toMap();
        float x = static_cast<float>(coordMap.value("x").toDouble());
        float y = static_cast<float>(coordMap.value("y").toDouble());
        coords.append(QVector2D(x, y));
    }

    if (!coords.isEmpty())
        geom.coordinates = coords;
    poi.geometry = geom;

    poi.details.metadata.clear();

    QVariantMap detailsMap = data.value("details").toMap(); // maps to JSON field "details"
    QVariantMap metadataMap = detailsMap.value("metadata").toMap(); // maps to "details.metadata"

    for (auto it = metadataMap.begin(); it != metadataMap.end(); ++it) {
        QString key = it.key();

        if (key == "note") {
            auto entry = QSharedPointer<NoteMetadataEntry>::create();
            entry->note = it.value().toString();
            poi.details.metadata.insert(key, entry);
        }
    }

    m_persistenceManager.save(poi);
}


void PoiController::updatePoiFromQml(const QVariantMap &data)
{
    Poi poi;

    poi.id = data.value("id").toString();
    poi.label = data.value("label").toString();
    poi.layerId = data.value("layerId").toInt();
    poi.typeId = data.value("typeId").toInt();
    poi.categoryId = data.value("categoryId").toInt();
    poi.healthStatusId = data.value("healthStatusId").toInt();
    poi.operationalStateId = data.value("operationalStateId").toInt();

    // Geometry
    QVariantMap geomMap = data.value("geometry").toMap();
    Geometry geom;
    geom.shapeTypeId = geomMap.value("shapeTypeId").toInt();
    geom.surface = geomMap.value("surface").toDouble();
    geom.height = geomMap.value("height").toDouble();

    QVariantMap centerCoordMap = geomMap.value("coordinate").toMap();
    geom.coordinate.setX(centerCoordMap.value("x").toDouble());
    geom.coordinate.setY(centerCoordMap.value("y").toDouble());

    geom.radiusA = geomMap.value("radiusA").toDouble();
    geom.radiusB = geomMap.value("radiusB").toDouble();

    QVariantList coordList = geomMap.value("coordinates").toList();
    QList<QVector2D> coords;
    for (const QVariant &coordVar : coordList) {
        QVariantMap coordMap = coordVar.toMap();
        float x = static_cast<float>(coordMap.value("x").toDouble());
        float y = static_cast<float>(coordMap.value("y").toDouble());
        coords.append(QVector2D(x, y));
    }

    if (!coords.isEmpty())
        geom.coordinates = coords;
    poi.geometry = geom;

    // Metadata
    poi.details.metadata.clear();

    QVariantMap detailsMap = data.value("details").toMap(); // this maps to JSON field "details"
    QVariantMap metadataMap = detailsMap.value("metadata").toMap(); // maps to "details.metadata"

    for (auto it = metadataMap.begin(); it != metadataMap.end(); ++it) {
        QString key = it.key();

        if (key == "note") {
            auto entry = QSharedPointer<NoteMetadataEntry>::create();
            entry->note = it.value().toString();
            poi.details.metadata.insert(key, entry);
        }
    }

    m_persistenceManager.update(poi);
}

void PoiController::deletePoiFromQml(const QString &id)
{
    if (id.isEmpty()) {
        emit poiDeleteFailed();
        return;
    }

    m_persistenceManager.remove(id);
}
