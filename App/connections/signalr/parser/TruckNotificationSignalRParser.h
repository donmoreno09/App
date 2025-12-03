#ifndef TRUCKNOTIFICATIONSIGNALRPARSER_H
#define TRUCKNOTIFICATIONSIGNALRPARSER_H

#include "ISignalRMessageParser.h"
#include <entities/TruckNotification.h>
#include <QDateTime>

/**
 * @brief Parser for Truck Notifications (EventType 0 and 1)
 *
 * EventType 0: TirAppIssueCreated
 * EventType 1: TirAppIssueResolved
 *
 * Parses SignalR envelope and Payload JSON into TruckNotification entities.
 *
 * IMPORTANT: Backend sends Payload as a JSON ARRAY STRING: "[{...}]"
 */
class TruckNotificationSignalRParser : public ISignalRMessageParser<TruckNotification> {
public:
    QVector<TruckNotification> parse(const QVariantMap& envelope) override {
        // Extract envelope fields
        QString id = envelope["Id"].toString();
        QString payloadStr = envelope["Payload"].toString();

        // Parse Payload JSON ARRAY (backend sends "[{...}]")
        QJsonDocument doc = QJsonDocument::fromJson(payloadStr.toUtf8());
        if (doc.isNull() || !doc.isArray()) {
            qWarning() << "[TruckNotificationSignalRParser] Payload is not a JSON array:" << payloadStr;
            return {};
        }

        QJsonArray payloadArray = doc.array();
        if (payloadArray.isEmpty()) {
            qWarning() << "[TruckNotificationSignalRParser] Payload array is empty";
            return {};
        }

        // Get first object from array
        QJsonObject payload = payloadArray[0].toObject();
        if (payload.isEmpty()) {
            qWarning() << "[TruckNotificationSignalRParser] Failed to parse Payload JSON object";
            return {};
        }

        // Create notification
        TruckNotification notif;

        // Use notification ID from payload (not envelope ID)
        // This is important for proper upsert behavior
        notif.id = payload["Id"].toString();
        notif.userId = extractUserId(envelope);

        // Parse payload fields
        notif.operationCode = payload["OperationCode"].toString();
        notif.operationId = payload["OperationId"].toString();

        // Location [lon, lat] format
        QJsonArray locArray = payload["Location"].toArray();
        if (locArray.size() >= 2) {
            notif.location = parseCoordinateArray(locArray, true);  // swap=true for [lon, lat]
        }

        // Handle nullable integers (use -1 as "null")
        notif.operationIssueTypeId = payload["OperationIssueTypeId"].isNull()
                                         ? -1
                                         : payload["OperationIssueTypeId"].toInt();

        notif.operationState = payload["OperationState"].toString();

        notif.operationIssueSolutionTypeId = payload["OperationIssueSolutionTypeId"].isNull()
                                                 ? -1
                                                 : payload["OperationIssueSolutionTypeId"].toInt();

        // Handle nullable strings
        notif.estimatedArrival = payload["EstimatedArrival"].isNull()
                                     ? QString()
                                     : payload["EstimatedArrival"].toString();

        notif.note = payload["Note"].isNull()
                         ? QString()
                         : payload["Note"].toString();

        notif.reportedAt = payload["ReportedAt"].toString();

        notif.solvedAt = payload["SolvedAt"].isNull()
                             ? QString()
                             : payload["SolvedAt"].toString();

        notif.isDeleted = payload["IsDeleted"].toBool();
        notif.createdAt = payload["CreatedAt"].toString();
        notif.updatedAt = payload["UpdatedAt"].toString();

        qDebug() << "[TruckNotificationSignalRParser] Parsed notification ID:" << notif.id
                 << "State:" << notif.operationState;

        return {notif};
    }
};

#endif // TRUCKNOTIFICATIONSIGNALRPARSER_H
