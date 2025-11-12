#ifndef ALERTZONE_H
#define ALERTZONE_H

#include <QString>
#include <QJsonObject>
#include <QJsonArray>
#include <QMap>
#include <QSharedPointer>
#include "../persistence/ipersistable.h"
#include "Geometry.h"

class AlertZone : public IPersistable
{
public:
    QString id;
    QString label;
    int layerId = 2;  // Hardcoded for alert zones
    QString layerName = "AlertZoneMapLayer";

    Geometry geometry;  // Polygon only

    QJsonObject toJson() const override {
        QJsonObject obj;
        obj["id"] = id;
        obj["label"] = label;
        obj["layerId"] = layerId;
        obj["layerName"] = layerName;
        obj["geometry"] = geometry.toJson();
        return obj;
    }

    void fromJson(const QJsonObject &obj) override {
        id = obj["id"].toString();
        label = obj["label"].toString();
        layerId = obj["layerId"].toInt();
        layerName = obj["layerName"].toString();
        geometry = Geometry::fromJson(obj["geometry"].toObject());
    }
};

#endif // ALERTZONE_H
