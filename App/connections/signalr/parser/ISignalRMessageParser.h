#ifndef ISIGNALRMESSAGEPARSER_H
#define ISIGNALRMESSAGEPARSER_H

#include <QVariantMap>
#include <QVector>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonDocument>
#include <QGeoCoordinate>

/**
 * @brief Base interface for SignalR message parsers
 *
 * Similar to IMessageParser for MQTT, but works with SignalR envelopes (QVariantMap)
 * instead of raw bytes (QByteArray).
 */
class IBaseSignalRMessageParser {
public:
    virtual ~IBaseSignalRMessageParser() = default;
};

/**
 * @brief Template interface for SignalR message parsers
 *
 * @tparam T Entity type (e.g., TruckNotification, AlertZoneNotification)
 *
 * Usage:
 *   class TruckNotificationSignalRParser : public ISignalRMessageParser<TruckNotification> {
 *       QVector<TruckNotification> parse(const QVariantMap& envelope) override;
 *   };
 */
template <class T>
class ISignalRMessageParser : public IBaseSignalRMessageParser {
public:
    virtual ~ISignalRMessageParser() = default;

    /**
     * @brief Parse SignalR envelope into entities
     * @param envelope The notification envelope: {Id, EventType, Payload, UserId}
     * @return Vector of parsed entities
     */
    virtual QVector<T> parse(const QVariantMap& envelope) = 0;

protected:
    /**
     * @brief Parse Payload string into QJsonObject
     * @param payloadStr JSON string from envelope["Payload"]
     * @return Parsed JSON object, or empty object if parsing fails
     */
    QJsonObject parsePayload(const QString& payloadStr) {
        QJsonDocument doc = QJsonDocument::fromJson(payloadStr.toUtf8());
        if (doc.isNull() || !doc.isObject()) {
            return QJsonObject();
        }
        return doc.object();
    }

    /**
     * @brief Parse coordinate array [lon, lat] or [lat, lon]
     * @param arr JSON array with coordinates
     * @param swap If true, treats as [lon, lat]; if false, treats as [lat, lon]
     * @return QGeoCoordinate
     */
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

    /**
     * @brief Extract UserId from envelope (handles both string and array)
     * @param envelope The notification envelope
     * @return First userId if array, or the string itself
     */
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
