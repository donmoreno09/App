#ifndef IMESSAGEPARSER_H
#define IMESSAGEPARSER_H

#include <QVariantList>
#include <QByteArray>
#include <QJsonArray>
#include <QGeoCoordinate>

class IBaseMessageParser {
public:
    virtual ~IBaseMessageParser() = default;
};

template <class T>
class IMessageParser : public IBaseMessageParser {
public:
    virtual ~IMessageParser() = default;
    virtual QVector<T> parse(const QByteArray& message) = 0;

protected:
    // Some store coordinate order in (lon, lat) instead of (lat, lon)
    // Use swap to use (lon, lat).
    QGeoCoordinate parseCoordinateArray(const QJsonArray &arr, bool swap = false) {
        QGeoCoordinate coord;
        coord.setLatitude(arr[swap ? 1 : 0].toDouble());
        coord.setLongitude(arr[swap ? 0 : 1].toDouble());
        coord.setAltitude(arr[2].toDouble());
        return coord;
    }
};

#endif // IMESSAGEPARSER_H
