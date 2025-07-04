#ifndef COORDINATES_H
#define COORDINATES_H

#include <QJsonObject>

struct Coordinates {
    double latitude;
    double longitude;

    QJsonObject toJson() const {
        QJsonObject obj;
        obj["latitude"] = latitude;
        obj["longitude"] = longitude;
        return obj;
    }

    static Coordinates fromJson(const QJsonObject &obj) {
        Coordinates c;
        c.latitude = obj["latitude"].toDouble();
        c.longitude = obj["longitude"].toDouble();
        return c;
    }
};

#endif // COORDINATES_H
