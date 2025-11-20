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
    int layerId;
    QString layerName;
    QString note;
    QString severity = "low";

    Geometry geometry;

    QJsonObject toJson() const override {
        QJsonObject obj;
        obj["id"] = id;
        obj["label"] = label;
        obj["layerId"] = layerId;
        obj["layerName"] = layerName;
        obj["note"] = note;
        obj["severity"] = severity;
        obj["geometry"] = geometry.toJson();
        return obj;
    }

    void fromJson(const QJsonObject &obj) override {
        id = obj["id"].toString();
        label = obj["label"].toString();
        layerId = obj["layerId"].toInt();
        layerName = obj["layerName"].toString();
        note = obj["note"].toString();
        severity = obj["severity"].toString("low");
        geometry = Geometry::fromJson(obj["geometry"].toObject());
    }
};

#endif // ALERTZONE_H
