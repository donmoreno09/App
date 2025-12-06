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
    int severity = 0;
    bool active = true;
    QMap<QString, bool> layers;

    Geometry geometry;

    Details details;

    QJsonObject toJson() const override {
        QJsonObject obj;
        obj["id"] = id;
        obj["label"] = label;
        obj["severity"] = severity;
        obj["enabled"] = active;

        QJsonObject layersObj;
        for (auto it = layers.begin(); it != layers.end(); ++it) {
            layersObj[it.key()] = it.value();
        }
        obj["layers"] = layersObj;

        obj["geometry"] = geometry.toJson();
        obj["details"] = details.toJson();
        return obj;
    }

    void fromJson(const QJsonObject &obj) override {
        id = obj["id"].toString();
        label = obj["label"].toString();
        severity = obj["severity"].toInt(0);
        active = obj["enabled"].toBool(true);

        layers.clear();
        const QJsonObject layersObj = obj["layers"].toObject();
        for (auto it = layersObj.begin(); it != layersObj.end(); ++it) {
            layers.insert(it.key(), it.value().toBool());
        }

        geometry = Geometry::fromJson(obj["geometry"].toObject());
        details.fromJson(obj["details"].toObject());
    }
};

#endif // ALERTZONE_H
