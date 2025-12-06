#ifndef TRUCKNOTIFICATIONSIGNALRPARSER_H
#define TRUCKNOTIFICATIONSIGNALRPARSER_H

#include "ISignalRMessageParser.h"
#include <entities/TruckNotification.h>
#include <QDateTime>

class TruckNotificationSignalRParser : public ISignalRMessageParser<TruckNotification> {
public:
    QVector<TruckNotification> parse(const QVariantMap& envelope) override {
        QString envelopeId = envelope["Id"].toString();
        QString payloadStr = envelope["Payload"].toString();

        QJsonDocument doc = QJsonDocument::fromJson(payloadStr.toUtf8());
        if (!doc.isArray()) {
            qWarning() << "[TruckNotificationSignalRParser] Payload is not an array";
            return {};
        }

        QJsonArray arr = doc.array();
        if (arr.isEmpty()) {
            qWarning() << "[TruckNotificationSignalRParser] Payload array empty";
            return {};
        }

        QJsonObject payload = arr.first().toObject();
        if (payload.isEmpty()) {
            qWarning() << "[TruckNotificationSignalRParser] Payload JSON invalid";
            return {};
        }

        TruckNotification notif;
        notif.id = payload["Id"].toString();
        notif.envelopeId = envelopeId;
        notif.userId = payload["UserId"].toString();
        notif.operationCode = payload["OperationCode"].toString();
        notif.operationId = payload["OperationId"].toString();

        QJsonArray locArray = payload["Location"].toArray();
        if (locArray.size() >= 2) {
            notif.location = parseCoordinateArray(locArray, true);
        }

        notif.operationIssueTypeId =
            payload["OperationIssueTypeId"].isNull() ? -1 : payload["OperationIssueTypeId"].toInt();

        notif.operationState = payload["OperationState"].toString();
        notif.operationIssueSolutionTypeId =
            payload["OperationIssueSolutionTypeId"].isNull() ? -1 : payload["OperationIssueSolutionTypeId"].toInt();

        notif.estimatedArrival = payload["EstimatedArrival"].toString();
        notif.note = payload["Note"].toString();
        notif.reportedAt = payload["ReportedAt"].toString();
        notif.solvedAt = payload["SolvedAt"].toString();
        notif.isDeleted = payload["IsDeleted"].toBool();
        notif.createdAt = payload["CreatedAt"].toString();
        notif.updatedAt = payload["UpdatedAt"].toString();

        return { notif };
    }
};

#endif // TRUCKNOTIFICATIONSIGNALRPARSER_H
