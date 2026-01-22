#ifndef ALERTZONENOTIFICATIONPARSER_H
#define ALERTZONENOTIFICATIONPARSER_H

#include "ISignalRMessageParser.h"
#include <entities/AlertZoneNotification.h>
#include <QDateTime>

class AlertZoneNotificationParser : public ISignalRMessageParser<AlertZoneNotification> {
public:
    QVector<AlertZoneNotification> parse(const QVariantMap& envelope) override {
        AlertZoneNotification notif;

        // Root level fields - support both PascalCase and lowercase
        notif.id = envelope.contains("id") ? envelope["id"].toString() : envelope["Id"].toString();
        notif.userId = envelope.contains("userId") ? envelope["userId"].toString() : extractUserId(envelope);
        notif.status = envelope.contains("status") ? envelope["status"].toInt() : envelope["Status"].toInt();
        notif.sentAt = envelope.contains("sentAt") ? envelope["sentAt"].toString() : envelope["SentAt"].toString();
        notif.createdAt = envelope.contains("createdAt") ? envelope["createdAt"].toString() : envelope["CreatedAt"].toString();
        notif.updatedAt = envelope.contains("updatedAt") ? envelope["updatedAt"].toString() : envelope["UpdatedAt"].toString();

        // Get payload - may be object or string
        QJsonObject payload = getPayloadObject(envelope);
        if (payload.isEmpty()) {
            qWarning() << "[AlertZoneNotificationParser] Failed to parse Payload JSON";
            return {};
        }

        // Parse nested AlertZone
        QJsonObject alertZoneObj = payload.contains("AlertZone") ? payload["AlertZone"].toObject() : payload["alertZone"].toObject();
        notif.alertZone.fromJson(alertZoneObj);

        // Parse nested TrackData
        QJsonObject trackDataObj = payload.contains("TrackData") ? payload["TrackData"].toObject() : payload["trackData"].toObject();
        notif.trackData = NotificationTrackData::fromJson(trackDataObj);

        // Payload-level fields
        notif.trackType = payload.contains("TrackType") ? payload["TrackType"].toString() : payload["trackType"].toString();
        notif.topic = payload.contains("Topic") ? payload["Topic"].toString() : payload["topic"].toString();
        notif.detectedAt = payload.contains("DetectedAt") ? payload["DetectedAt"].toString() : payload["detectedAt"].toString();

        notif.isRead = false;
        notif.isDeleted = false;

        return { notif };
    }

private:
    QJsonObject getPayloadObject(const QVariantMap& envelope) {
        QVariant payloadVar = envelope.contains("payload") ? envelope["payload"] : envelope["Payload"];

        // Check if payload is already an object/map
        if (payloadVar.typeId() == QMetaType::QVariantMap) {
            return QJsonObject::fromVariantMap(payloadVar.toMap());
        }

        // If payload is a string, parse it as JSON
        if (payloadVar.typeId() == QMetaType::QString) {
            return parsePayload(payloadVar.toString());
        }

        // Try to convert to JSON object
        QJsonValue jsonVal = QJsonValue::fromVariant(payloadVar);
        if (jsonVal.isObject()) {
            return jsonVal.toObject();
        }

        return QJsonObject();
    }
};

#endif // ALERTZONENOTIFICATIONPARSER_H
