#ifndef ALERTZONENOTIFICATIONPARSER_H
#define ALERTZONENOTIFICATIONPARSER_H

#include "ISignalRMessageParser.h"
#include <entities/AlertZoneNotification.h>
#include <QDateTime>

class AlertZoneNotificationParser : public ISignalRMessageParser<AlertZoneNotification> {
public:
    QVector<AlertZoneNotification> parse(const QVariantMap& envelope) override {
        QString id = envelope["Id"].toString();
        QString payloadStr = envelope["Payload"].toString();

        QJsonObject payload = parsePayload(payloadStr);
        if (payload.isEmpty()) {
            qWarning() << "[AlertZoneNotificationParser] Failed to parse Payload JSON";
            return {};
        }

        AlertZoneNotification notif;

        notif.id = id;
        notif.userId = extractUserId(envelope);
        notif.title = payload["title"].toString();
        notif.message = payload["message"].toString();
        notif.timestamp = payload["timestamp"].toString();
        notif.trackId = payload["TrackId"].toString();
        notif.trackName = payload["TrackName"].toString();
        notif.alertZoneId = payload["AlertZoneId"].toString();
        notif.alertZoneName = payload["AlertZoneName"].toString();

        if (payload.contains("Location")) {
            QJsonArray locArray = payload["Location"].toArray();
            if (locArray.size() >= 2) {
                notif.location = parseCoordinateArray(locArray, true);
            }
        }

        notif.createdAt = QDateTime::currentDateTime().toString(Qt::ISODate);
        notif.isRead = false;
        notif.isDeleted = false;

        return { notif };
    }
};

#endif // ALERTZONENOTIFICATIONPARSER_H
