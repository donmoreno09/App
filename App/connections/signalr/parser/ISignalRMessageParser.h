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
    QJsonObject parsePayload(const QString& payloadStr) {
        QJsonDocument doc = QJsonDocument::fromJson(payloadStr.toUtf8());
        if (doc.isNull() || !doc.isObject()) {
            return QJsonObject();
        }
        return doc.object();
    }

    QGeoCoordinate parseCoordinateArray(const QJsonArray& arr, bool swap = false) {
        QGeoCoordinate coord;
        if (arr.size() >= 2) {
            coord.setLatitude(arr[swap ? 1 : 0].toDouble());
            coord.setLongitude(arr[swap ? 0 : 1].toDouble());
            if (arr.size() >= 3) {
                coord.setAltitude(arr[2].toDouble());
            }
        }
        return coord;
    }

    QString extractUserId(const QVariantMap& envelope) {
        QVariant userIdVar = envelope["UserId"];
        if (userIdVar.canConvert<QVariantList>()) {
            QVariantList userIds = userIdVar.toList();
            if (!userIds.isEmpty()) {
                return userIds[0].toString();
            }
        }
        return userIdVar.toString();
    }
};

#endif // ISIGNALRMESSAGEPARSER_H
