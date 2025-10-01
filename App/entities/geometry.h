#ifndef GEOMETRY_H
#define GEOMETRY_H

#include <QJsonObject>
#include <QJsonArray>
#include <QVector2D>

struct Geometry {
    int shapeTypeId = 0;
    double surface = 0.0;
    double height = 0.0;

    QList<QVector2D> coordinates;
    QVector2D coordinate;

    double radiusA = 0.0;
    double radiusB = 0.0;

    QJsonObject toJson() const {
        QJsonObject obj;
        obj["shapeTypeId"] = shapeTypeId;
        obj["surface"] = surface;
        obj["height"] = height;

        QJsonArray coordsArray;
        for (const auto& point : coordinates) {
            QJsonObject p;
            p["x"] = point.x();
            p["y"] = point.y();
            coordsArray.append(p);
        }
        obj["coordinates"] = coordsArray;

        QJsonObject singleCoord;
        singleCoord["x"] = coordinate.x();
        singleCoord["y"] = coordinate.y();
        obj["coordinate"] = singleCoord;

        obj["radiusA"] = radiusA;
        obj["radiusB"] = radiusB;

        return obj;
    }

    static Geometry fromJson(const QJsonObject& obj) {
        Geometry g;
        g.shapeTypeId = obj["shapeTypeId"].toInt();
        g.surface = obj["surface"].toDouble();
        g.height = obj["height"].toDouble();

        QJsonArray coordsArray = obj["coordinates"].toArray();
        for (const QJsonValue& val : coordsArray) {
            QJsonObject p = val.toObject();
            g.coordinates.append(QVector2D(p["x"].toDouble(), p["y"].toDouble()));
        }

        QJsonObject coordObj = obj["coordinate"].toObject();
        g.coordinate = QVector2D(coordObj["x"].toDouble(), coordObj["y"].toDouble());

        g.radiusA = obj["radiusA"].toDouble();
        g.radiusB = obj["radiusB"].toDouble();

        return g;
    }
};

#endif // GEOMETRY_H
