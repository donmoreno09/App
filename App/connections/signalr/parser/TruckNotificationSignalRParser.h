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
 */
class TruckNotificationSignalRParser : public ISignalRMessageParser<TruckNotification> {
public:
    QVector<TruckNotification> parse(const QVariantMap& envelope) override {
        // Extract envelope fields
        QString id = envelope["Id"].toString();
        QString payloadStr = envelope["Payload"].toString();

        // Parse Payload JSON
        QJsonObject payload = parsePayload(payloadStr);
        if (payload.isEmpty()) {
            qWarning() << "[TruckNotificationSignalRParser] Failed to parse Payload JSON";
            return {};
        }

        // Create notification
        TruckNotification notif;
        notif.id = id;
        notif.userId = extractUserId(envelope);

        // Parse payload fields
        notif.operationCode = payload["OperationCode"].toString();
        notif.operationId = payload["OperationId"].toString();

        // Location [lon, lat] format
        QJsonArray locArray = payload["Location"].toArray();
        if (locArray.size() >= 2) {
            notif.location = parseCoordinateArray(locArray, true);  // swap=true for [lon, lat]
        }

        notif.operationIssueTypeId = payload["OperationIssueTypeId"].toInt();
        notif.operationState = payload["OperationState"].toString();
        notif.operationIssueSolutionTypeId = payload["OperationIssueSolutionTypeId"].toInt();
        notif.estimatedArrival = payload["EstimatedArrival"].toString();
        notif.note = payload["Note"].toString();
        notif.reportedAt = payload["ReportedAt"].toString();
        notif.solvedAt = payload["SolvedAt"].toString();
        notif.isDeleted = payload["IsDeleted"].toBool();
        notif.createdAt = payload["CreatedAt"].toString();
        notif.updatedAt = payload["UpdatedAt"].toString();

        return {notif};
    }
};

#endif // TRUCKNOTIFICATIONSIGNALRPARSER_H
