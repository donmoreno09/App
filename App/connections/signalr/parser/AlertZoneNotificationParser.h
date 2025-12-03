#ifndef ALERTZONENOTIFICATIONPARSER_H
#define ALERTZONENOTIFICATIONPARSER_H

#include "ISignalRMessageParser.h"
#include <entities/AlertZoneNotification.h>
#include <QDateTime>

/**
 * @brief Parser for Alert Zone Notifications (EventType 2)
 *
 * EventType 2: ControlRoomAlertZoneIntrusion
 *
 * Parses SignalR envelope and Payload JSON into AlertZoneNotification entities.
 */
class AlertZoneNotificationParser : public ISignalRMessageParser<AlertZoneNotification> {
public:
    QVector<AlertZoneNotification> parse(const QVariantMap& envelope) override {
        // Extract envelope fields
        QString id = envelope["Id"].toString();
        QString payloadStr = envelope["Payload"].toString();

        // Parse Payload JSON
        QJsonObject payload = parsePayload(payloadStr);
        if (payload.isEmpty()) {
            qWarning() << "[AlertZoneNotificationParser] Failed to parse Payload JSON";
            return {};
        }

        // Create notification
        AlertZoneNotification notif;
        notif.id = id;
        notif.userId = extractUserId(envelope);

        // Parse payload fields (your test payload has: title, message, timestamp)
        notif.title = payload["title"].toString();
        notif.message = payload["message"].toString();
        notif.timestamp = payload["timestamp"].toString();

        // Optional fields (may not be in all payloads)
        notif.trackId = payload["TrackId"].toString();
        notif.trackName = payload["TrackName"].toString();
        notif.alertZoneId = payload["AlertZoneId"].toString();
        notif.alertZoneName = payload["AlertZoneName"].toString();

        // Location (if available)
        if (payload.contains("Location")) {
            QJsonArray locArray = payload["Location"].toArray();
            if (locArray.size() >= 2) {
                notif.location = parseCoordinateArray(locArray, true);  // swap=true for [lon, lat]
            }
        }

        // Metadata
        notif.createdAt = QDateTime::currentDateTime().toString(Qt::ISODate);
        notif.isRead = false;
        notif.isDeleted = false;

        return {notif};
    }
};

#endif // ALERTZONENOTIFICATIONPARSER_H
