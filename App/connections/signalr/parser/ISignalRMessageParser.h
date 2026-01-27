#ifndef ISIGNALRMESSAGEPARSER_H
#define ISIGNALRMESSAGEPARSER_H

#include <QVariantMap>
#include <QVector>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonDocument>
#include <QGeoCoordinate>


class IBaseSignalRMessageParser {
public:
    virtual ~IBaseSignalRMessageParser() = default;
};

template <class T>

class ISignalRMessageParser : public IBaseSignalRMessageParser {
public:
    virtual ~ISignalRMessageParser() = default;
    virtual QVector<T> parse(const QVariantMap& envelope) = 0;

protected:
    // Parse coordinate array [lat, lon] or [lat, lon, altitude]
    QGeoCoordinate parseCoordinateArray(const QJsonArray& arr) {
        QGeoCoordinate coord;
        if (arr.size() >= 2) {
            coord.setLatitude(arr[0].toDouble());
            coord.setLongitude(arr[1].toDouble());
            if (arr.size() >= 3) {
                coord.setAltitude(arr[2].toDouble());
            }
        }
        return coord;
    }
};

#endif // ISIGNALRMESSAGEPARSER_H
