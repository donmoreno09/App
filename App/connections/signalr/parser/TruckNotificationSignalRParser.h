#ifndef TRUCKNOTIFICATIONSIGNALRPARSER_H
#define TRUCKNOTIFICATIONSIGNALRPARSER_H

#include "ISignalRMessageParser.h"
#include <entities/TruckNotification.h>

class TruckNotificationSignalRParser : public ISignalRMessageParser<TruckNotification> {
public:
    QVector<TruckNotification> parse(const QVariantMap& envelope) override {
        QString envelopeId = envelope["Id"].toString();
        QVariant payloadVar = envelope["Payload"];

        QJsonObject payload = QJsonObject::fromVariantMap(payloadVar.toMap());

        if (payload.isEmpty()) {
            qWarning() << "[TruckNotificationSignalRParser] Payload is empty or invalid";
            return {};
        }

        TruckNotification notif;

        notif.id = payload["IssueId"].toString();
        notif.envelopeId = envelopeId;
        notif.userId = payload["UserId"].toString();
        notif.operationCode = payload["OperationCode"].toString();
        notif.operationId = payload["OperationId"].toString();

        // Parse Location object {Latitude, Longitude}
        QJsonObject locObj = payload["Location"].toObject();
        if (!locObj.isEmpty()) {
            double lat = locObj["Latitude"].toDouble();
            double lon = locObj["Longitude"].toDouble();
            notif.location = QGeoCoordinate(lat, lon);
        }

        notif.operationState = payload["OperationState"].toString();
        notif.issueType = payload["IssueType"].toString();
        notif.solutionType = payload["SolutionType"].toString();
        notif.estimatedArrival = payload["EstimatedArrival"].toString();
        notif.note = payload["Note"].toString();
        notif.reportedAt = payload["ReportedAt"].toString();
        notif.solvedAt = payload["SolvedAt"].toString();
        notif.createdAt = payload["CreatedAt"].toString();
        notif.timestamp = payload["Timestamp"].toString();

        return { notif };
    }
};

#endif // TRUCKNOTIFICATIONSIGNALRPARSER_H
