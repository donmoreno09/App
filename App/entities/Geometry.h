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

        // Support both PascalCase and lowercase keys
        g.shapeTypeId = obj.contains("ShapeTypeId") ? obj["ShapeTypeId"].toInt() : obj["shapeTypeId"].toInt();
        g.surface = obj.contains("Surface") ? obj["Surface"].toDouble() : obj["surface"].toDouble();
        g.height = obj.contains("Height") ? obj["Height"].toDouble() : obj["height"].toDouble();

        QJsonArray coordsArray = obj.contains("Coordinates") ? obj["Coordinates"].toArray() : obj["coordinates"].toArray();
        for (const QJsonValue& val : coordsArray) {
            QJsonObject p = val.toObject();
            double x = p.contains("X") ? p["X"].toDouble() : p["x"].toDouble();
            double y = p.contains("Y") ? p["Y"].toDouble() : p["y"].toDouble();
            g.coordinates.append(QVector2D(x, y));
        }

        QJsonObject coordObj = obj.contains("Coordinate") ? obj["Coordinate"].toObject() : obj["coordinate"].toObject();
        double cx = coordObj.contains("X") ? coordObj["X"].toDouble() : coordObj["x"].toDouble();
        double cy = coordObj.contains("Y") ? coordObj["Y"].toDouble() : coordObj["y"].toDouble();
        g.coordinate = QVector2D(cx, cy);

        g.radiusA = obj.contains("RadiusA") ? obj["RadiusA"].toDouble() : obj["radiusA"].toDouble();
        g.radiusB = obj.contains("RadiusB") ? obj["RadiusB"].toDouble() : obj["radiusB"].toDouble();

        return g;
    }
};

#endif // GEOMETRY_H
