#ifndef ALERTZONENOTIFICATIONPARSER_H
#define ALERTZONENOTIFICATIONPARSER_H

#include "ISignalRMessageParser.h"
#include <entities/AlertZoneNotification.h>

class AlertZoneNotificationParser : public ISignalRMessageParser<AlertZoneNotification> {
public:
    QVector<AlertZoneNotification> parse(const QVariantMap& envelope) override {
        AlertZoneNotification notif;

        // Envelope fields (built by SignalRClientService with PascalCase)
        notif.id = envelope["Id"].toString();
        notif.userId = envelope["UserId"].toString();
        notif.status = envelope["Status"].toInt();
        notif.sentAt = envelope["SentAt"].toString();
        notif.createdAt = envelope["CreatedAt"].toString();
        notif.updatedAt = envelope["UpdatedAt"].toString();

        // Get payload as object
        QVariant payloadVar = envelope["Payload"];
        QJsonObject payload = QJsonObject::fromVariantMap(payloadVar.toMap());

        if (payload.isEmpty()) {
            qWarning() << "[AlertZoneNotificationParser] Payload is empty or invalid";
            return {};
        }

        // Parse nested AlertZone
        QJsonObject alertZoneObj = payload["AlertZone"].toObject();
        notif.alertZone.fromJson(alertZoneObj);

        // Parse nested TrackData
        QJsonObject trackDataObj = payload["TrackData"].toObject();
        notif.trackData = NotificationTrackData::fromJson(trackDataObj);

        // Payload-level fields
        notif.trackType = payload["TrackType"].toString();
        notif.topic = payload["Topic"].toString();
        notif.detectedAt = payload["DetectedAt"].toString();

        notif.isRead = false;
        notif.isDeleted = false;

        return { notif };
    }
};

#endif // ALERTZONENOTIFICATIONPARSER_H
