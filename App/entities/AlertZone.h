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
        // Support both PascalCase and lowercase keys
        id = obj.contains("Id") ? obj["Id"].toString() : obj["id"].toString();
        label = obj.contains("Label") ? obj["Label"].toString() : obj["label"].toString();
        severity = obj.contains("Severity") ? obj["Severity"].toInt(0) : obj["severity"].toInt(0);
        active = obj.contains("Enabled") ? obj["Enabled"].toBool(true) : obj["enabled"].toBool(true);

        layers.clear();
        const QJsonObject layersObj = obj.contains("Layers") ? obj["Layers"].toObject() : obj["layers"].toObject();
        for (auto it = layersObj.begin(); it != layersObj.end(); ++it) {
            layers.insert(it.key(), it.value().toBool());
        }

        QJsonObject geometryObj = obj.contains("Geometry") ? obj["Geometry"].toObject() : obj["geometry"].toObject();
        geometry = Geometry::fromJson(geometryObj);

        if (obj.contains("details") || obj.contains("Details")) {
            QJsonObject detailsObj = obj.contains("Details") ? obj["Details"].toObject() : obj["details"].toObject();
            details.fromJson(detailsObj);
        }
    }
};

#endif // ALERTZONE_H
