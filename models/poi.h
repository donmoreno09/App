#ifndef POI_H
#define POI_H

#include <QString>
#include <QJsonObject>
#include <QJsonArray>
#include <QMap>
#include <QSharedPointer>
#include "../persistence/ipersistable.h"
#include "geometry.h"
#include "details.h"

class Poi : public IPersistable
{
public:
    QString id;
    QString label;
    int layerId = 0;
    QString layerName;
    int typeId = 0;
    QString typeName;
    int categoryId = 0;
    QString categoryName;
    int healthStatusId = 0;
    QString healthStatusName;
    int operationalStateId = 0;
    QString operationalStateName;

    Geometry geometry;

    Details details;

    QJsonObject toJson() const override {
        QJsonObject obj;
        obj["id"] = id;
        obj["label"] = label;
        obj["layerId"] = layerId;
        obj["layerName"] = layerName;
        obj["typeId"] = typeId;
        obj["typeName"] = typeName;
        obj["categoryId"] = categoryId;
        obj["categoryName"] = categoryName;
        obj["healthStatusId"] = healthStatusId;
        obj["healthStatusName"] = healthStatusName;
        obj["operationalStateId"] = operationalStateId;
        obj["operationalStateName"] = operationalStateName;
        obj["geometry"] = geometry.toJson();
        obj["details"] = details.toJson();
        return obj;
    }

    void fromJson(const QJsonObject &obj) override {
        id = obj["id"].toString();
        label = obj["label"].toString();
        layerId = obj["layerId"].toInt();
        layerName = obj["layerName"].toString();
        typeId = obj["typeId"].toInt();
        typeName = obj["typeName"].toString();
        categoryId = obj["categoryId"].toInt();
        categoryName = obj["categoryName"].toString();
        healthStatusId = obj["healthStatusId"].toInt();
        healthStatusName = obj["healthStatusName"].toString();
        operationalStateId = obj["operationalStateId"].toInt();
        operationalStateName = obj["operationalStateName"].toString();
        geometry = Geometry::fromJson(obj["geometry"].toObject());
        details.fromJson(obj["details"].toObject());
    }
};

#endif // POI_H
