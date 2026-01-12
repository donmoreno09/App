#ifndef TRUCKNOTIFICATIONPARSER_H
#define TRUCKNOTIFICATIONPARSER_H

#include "interfaces/IMessageParser.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QVector>
#include <QGeoCoordinate>
#include <entities/TruckNotification.h>

class TruckNotificationParser : public IMessageParser<TruckNotification> {
public:
    QVector<TruckNotification> parse(const QByteArray& message) override {
        // qDebug() << "[TruckNotificationParser] RAW MESSAGE:" << message;

        QJsonParseError err;
        QJsonDocument doc = QJsonDocument::fromJson(message, &err);
        if (err.error != QJsonParseError::NoError || !doc.isArray()) {
            return {};
        }

        QVector<TruckNotification> notifications;
        QJsonArray rawNotifications = doc.array();

        for (const QJsonValue& rawNotif : std::as_const(rawNotifications)) {
            if (!rawNotif.isObject()) continue;

            auto notifVal = rawNotif.toObject();

            TruckNotification notif;
            notif.id = notifVal["Id"].toString();
            notif.userId = notifVal["UserId"].toString();
            notif.operationId = notifVal["OperationId"].toString();
            notif.operationCode = notifVal["OperationCode"].toString();

            // Parse Location array [lat, lon] with swap=true for [lon, lat] format
            QJsonArray locArray = notifVal["Location"].toArray();
            if (locArray.size() >= 2) {
                notif.location = parseCoordinateArray(locArray, true);
            }

            notif.operationIssueTypeId = notifVal["OperationIssueTypeId"].toInt();
            notif.operationState = notifVal["OperationState"].toString();
            notif.operationIssueSolutionTypeId = notifVal["OperationIssueSolutionTypeId"].toInt();
            notif.estimatedArrival = notifVal["EstimatedArrival"].toString();
            notif.note = notifVal["Note"].toString();
            notif.reportedAt = notifVal["ReportedAt"].toString();
            notif.solvedAt = notifVal["SolvedAt"].toString();
            notif.isDeleted = notifVal["IsDeleted"].toBool();
            notif.createdAt = notifVal["CreatedAt"].toString();
            notif.updatedAt = notifVal["UpdatedAt"].toString();

            notifications.append(notif);
        }

        return notifications;
    }
};

#endif // TRUCKNOTIFICATIONPARSER_H
