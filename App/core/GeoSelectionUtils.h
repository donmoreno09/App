#ifndef GEOSELECTIONUTILS_H
#define GEOSELECTIONUTILS_H
#include <QVariant>
#include <QGeoCoordinate>

namespace GeoSelection {

enum class ShapeType {
    Point       = 1,
    LineString  = 2,
    Polygon     = 3,
    Circle      = 4,
    Ellipse     = 5
};

struct BBox {
    double xMin;
    double xMax;
    double yMin;
    double yMax;
};

inline bool intersects(const BBox& a, const BBox& b)
{
    return !(a.xMax < b.xMin
          || a.xMin > b.xMax
          || a.yMax < b.yMin
          || a.yMin > b.yMax);
}

inline bool contains(const BBox& outer, const BBox& inner)
{
    return inner.xMin >= outer.xMin
        && inner.xMax <= outer.xMax
        && inner.yMin >= outer.yMin
        && inner.yMax <= outer.yMax;
}

inline BBox bboxFromGeometry(const QVariantMap& geo)
{
    const ShapeType shape = static_cast<ShapeType>(geo.value("shapeTypeId").toInt());

    switch (shape) {
    case ShapeType::Point: {
        auto coord = geo.value("coordinate").toMap();

        double x = coord.value("x").toDouble();
        double y = coord.value("y").toDouble();

        return {x, x, y, y};
    }

    case ShapeType::LineString:
    case ShapeType::Polygon: {
        double xMin =  std::numeric_limits<double>::infinity();
        double xMax = -std::numeric_limits<double>::infinity();
        double yMin =  std::numeric_limits<double>::infinity();
        double yMax = -std::numeric_limits<double>::infinity();

        const auto coordinates = geo.value("coordinates").toList();
        for (auto it = coordinates.cbegin(); it != coordinates.cend(); it++) {
            auto coord = it->toMap();

            double x = coord.value("x").toDouble();
            double y = coord.value("y").toDouble();

            xMin = qMin(xMin, x);
            xMax = qMax(xMax, x);
            yMin = qMin(yMin, y);
            yMax = qMax(yMax, y);
        }

        return {xMin, xMax, yMin, yMax};
    }

    case ShapeType::Circle:
    case ShapeType::Ellipse: {
        auto coord = geo.value("coordinate").toMap();

        double cx = coord.value("x").toDouble();
        double cy = coord.value("y").toDouble();
        double rA = geo.value("radiusA").toDouble(); // radiusA => longitude => x
        double rB = geo.value("radiusB").toDouble(); // radiusB => latitude => y

        return {cx - rA, cx + rA, cy - rB, cy + rB};
    }

    default: return {0,0,0,0};
    }
}

inline QVariantList selectInRect(const QVariantList& items, const QGeoCoordinate& topLeft, const QGeoCoordinate& bottomRight)
{
    BBox selectionBox {
        qMin(topLeft.longitude(),  bottomRight.longitude()), // xMin
        qMax(topLeft.longitude(),  bottomRight.longitude()), // xMax
        qMin(topLeft.latitude(), bottomRight.latitude()),    // yMin
        qMax(topLeft.latitude(), bottomRight.latitude())     // yMax
    };

    QVariantList selectedGeos;

    for (const QVariant& item : items) {
        QVariantMap obj  = item.toMap();
        QVariantMap geom = obj.value("geometry").toMap();

        if (contains(selectionBox, bboxFromGeometry(geom))) {
            selectedGeos.append(item);
        }
    }

    return selectedGeos;
}

} // namespace GeoSelection

#endif // GEOSELECTIONUTILS_H
