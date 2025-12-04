#ifndef TRUCKNOTIFICATIONSIGNALRPARSER_H
#define TRUCKNOTIFICATIONSIGNALRPARSER_H

#include "ISignalRMessageParser.h"
#include <entities/TruckNotification.h>
#include <QDateTime>

class TruckNotificationSignalRParser : public ISignalRMessageParser<TruckNotification> {
public:
    QVector<TruckNotification> parse(const QVariantMap& envelope) override {
        QString payloadStr = envelope["Payload"].toString();

        QJsonObject payload = parsePayload(payloadStr);
        if (payload.isEmpty()) {
            qWarning() << "[TruckNotificationSignalRParser] Failed to parse Payload JSON";
            return {};
        }

        TruckNotification notif;

        notif.id = payload["Id"].toString();
        notif.userId = payload["UserId"].toString();
        notif.operationCode = payload["OperationCode"].toString();
        notif.operationId = payload["OperationId"].toString();

        QJsonArray locArray = payload["Location"].toArray();
        if (locArray.size() >= 2) {
            notif.location = parseCoordinateArray(locArray, true);
        }

        notif.operationIssueTypeId = payload["OperationIssueTypeId"].isNull() ? -1 : payload["OperationIssueTypeId"].toInt();
        notif.operationState = payload["OperationState"].toString();
        notif.operationIssueSolutionTypeId = payload["OperationIssueSolutionTypeId"].isNull() ? -1 : payload["OperationIssueSolutionTypeId"].toInt();
        notif.estimatedArrival = payload["EstimatedArrival"].isNull() ? QString() : payload["EstimatedArrival"].toString();
        notif.note = payload["Note"].isNull() ? QString() : payload["Note"].toString();
        notif.reportedAt = payload["ReportedAt"].toString();
        notif.solvedAt = payload["SolvedAt"].isNull() ? QString() : payload["SolvedAt"].toString();
        notif.isDeleted = payload["IsDeleted"].toBool();
        notif.createdAt = payload["CreatedAt"].toString();
        notif.updatedAt = payload["UpdatedAt"].toString();

        qDebug() << "[TruckNotificationSignalRParser] Parsed notification ID:" << notif.id << "State:" << notif.operationState;

        return { notif };
    }
};

#endif // TRUCKNOTIFICATIONSIGNALRPARSER_H
