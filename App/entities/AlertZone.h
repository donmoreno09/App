#ifndef ALERTZONE_H
#define ALERTZONE_H

#include <QString>
#include <QStringList>
#include <QJsonObject>
#include <QJsonArray>
#include <QMap>
#include <QSharedPointer>
#include "../persistence/ipersistable.h"
#include "Geometry.h"
#include "Details.h"

class AlertZone : public IPersistable
{
public:
    QString id;
    QString label;
    int layerId = 0;
    QString layerName;
    QString severity = "low";
    bool active = true;
    QStringList targetLayers;

    Geometry geometry;

    Details details;

    QJsonObject toJson() const override {
        QJsonObject obj;
        obj["id"] = id;
        obj["label"] = label;
        obj["layerId"] = layerId;
        obj["layerName"] = layerName;
        obj["severity"] = severity;
        obj["active"] = active;
        obj["targetLayers"] = QJsonArray::fromStringList(targetLayers);
        obj["geometry"] = geometry.toJson();
        obj["details"] = details.toJson();
        return obj;
    }

    void fromJson(const QJsonObject &obj) override {
        id = obj["id"].toString();
        label = obj["label"].toString();
        layerId = obj["layerId"].toInt();
        layerName = obj["layerName"].toString();
        severity = obj["severity"].toString("low");
        active = obj["active"].toBool(true);

        targetLayers.clear();
        const QJsonArray arr = obj["targetLayers"].toArray();
        for (const auto& v : arr) {
            targetLayers.append(v.toString());
        }

        geometry = Geometry::fromJson(obj["geometry"].toObject());
        details.fromJson(obj["details"].toObject());
    }
};

#endif // ALERTZONE_H
