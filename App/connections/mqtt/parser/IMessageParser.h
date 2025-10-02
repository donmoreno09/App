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
    QGeoCoordinate parseCoordinateArray(const QJsonArray &arr) {
        QGeoCoordinate coord;
        coord.setLatitude(arr[0].toDouble());
        coord.setLongitude(arr[1].toDouble());
        coord.setAltitude(arr[2].toDouble());
        return coord;
    }
};

#endif // IMESSAGEPARSER_H
