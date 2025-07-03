#ifndef SHAPE_H
#define SHAPE_H

#include "../persistence/ipersistable.h"
#include "geometry.h"

#include <QString>
#include <QJsonObject>
#include <QJsonArray>

class Shape : public IPersistable
{
public:
    QString id;
    QString label;
    Geometry geometry;

    QJsonObject toJson() const override {
        QJsonObject obj;
        obj["id"] = id;
        obj["label"] = label;
        obj["geometry"] = geometry.toJson();
        return obj;
    }

    void fromJson(const QJsonObject &obj) override {
        id = obj["id"].toString();
        label = obj["label"].toString();
        geometry = Geometry::fromJson(obj["geometry"].toObject());
    }
};

#endif // SHAPE_H
