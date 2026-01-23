#ifndef TRUCKNOTIFICATIONSIGNALRPARSER_H
#define TRUCKNOTIFICATIONSIGNALRPARSER_H

#include "ISignalRMessageParser.h"
#include <entities/TruckNotification.h>
#include <QDateTime>

class TruckNotificationSignalRParser : public ISignalRMessageParser<TruckNotification> {
public:
    QVector<TruckNotification> parse(const QVariantMap& envelope) override {
        QString envelopeId = envelope["Id"].toString();
        QVariant payloadVar = envelope["Payload"];

        QJsonObject payload;

        // Handle payload as either object or JSON string (for backwards compatibility)
        if (payloadVar.typeId() == QMetaType::QVariantMap) {
            payload = QJsonObject::fromVariantMap(payloadVar.toMap());
        } else {
            // Legacy format: payload is a JSON string containing an array
            QString payloadStr = payloadVar.toString();
            QJsonDocument doc = QJsonDocument::fromJson(payloadStr.toUtf8());
            if (doc.isArray()) {
                QJsonArray arr = doc.array();
                if (!arr.isEmpty()) {
                    payload = arr.first().toObject();
                }
            }
        }

        if (payload.isEmpty()) {
            qWarning() << "[TruckNotificationSignalRParser] Payload is empty or invalid";
            return {};
        }

        TruckNotification notif;

        // Map IssueId (new) or Id (legacy) to id
        notif.id = payload.contains("IssueId")
                       ? payload["IssueId"].toString()
                       : payload["Id"].toString();

        notif.envelopeId = envelopeId;
        notif.userId = payload["UserId"].toString();
        notif.operationCode = payload["OperationCode"].toString();
        notif.operationId = payload["OperationId"].toString();

        // Parse Location: new format is {Longitude, Latitude}, legacy is [lat, lon] array
        if (payload.contains("Location")) {
            QJsonValue locValue = payload["Location"];
            if (locValue.isObject()) {
                // New format: {Longitude: x, Latitude: y}
                QJsonObject locObj = locValue.toObject();
                double lat = locObj["Latitude"].toDouble();
                double lon = locObj["Longitude"].toDouble();
                notif.location = QGeoCoordinate(lat, lon);
            } else if (locValue.isArray()) {
                // Legacy format: [lat, lon]
                QJsonArray locArray = locValue.toArray();
                if (locArray.size() >= 2) {
                    notif.location = parseCoordinateArray(locArray, true);
                }
            }
        }

        notif.operationState = payload["OperationState"].toString();

        // Map IssueType (new string) or OperationIssueTypeId (legacy int)
        if (payload.contains("IssueType")) {
            notif.issueType = payload["IssueType"].toString();
        } else if (payload.contains("OperationIssueTypeId") && !payload["OperationIssueTypeId"].isNull()) {
            // Convert legacy int to string for backwards compatibility
            notif.issueType = mapLegacyIssueType(payload["OperationIssueTypeId"].toInt());
        }

        // Map SolutionType (new string) or OperationIssueSolutionTypeId (legacy int)
        if (payload.contains("SolutionType")) {
            notif.solutionType = payload["SolutionType"].toString();
        } else if (payload.contains("OperationIssueSolutionTypeId") && !payload["OperationIssueSolutionTypeId"].isNull()) {
            // Convert legacy int to string for backwards compatibility
            notif.solutionType = mapLegacySolutionType(payload["OperationIssueSolutionTypeId"].toInt());
        }

        notif.estimatedArrival = payload["EstimatedArrival"].toString();
        notif.note = payload["Note"].toString();
        notif.reportedAt = payload["ReportedAt"].toString();
        notif.solvedAt = payload["SolvedAt"].toString();
        notif.createdAt = payload["CreatedAt"].toString();
        notif.timestamp = payload["Timestamp"].toString();

        return { notif };
    }

private:
    // Map legacy integer issue type IDs to string values
    QString mapLegacyIssueType(int typeId) {
        switch (typeId) {
        case 1: return "INCIDENT";
        case 2: return "PROBLEM_WITH_GOODS";
        case 3: return "COLLISION";
        case 4: return "DELAY";
        default: return "";
        }
    }

    // Map legacy integer solution type IDs to string values
    QString mapLegacySolutionType(int typeId) {
        switch (typeId) {
        case 1: return "OPERATION_CANCELED";
        case 2: return "RESCHEDULED";
        case 3: return "OTHER";
        default: return "";
        }
    }
};

#endif // TRUCKNOTIFICATIONSIGNALRPARSER_H
