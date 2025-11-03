#ifndef TRUCKNOTIFICATION_H
#define TRUCKNOTIFICATION_H

#include <QString>
#include <QGeoCoordinate>
#include <QDateTime>

class TruckNotification
{
public:
    QString id;                           // Id
    QString userId;                       // UserId
    QString operationId;                  // OperationId
    QString operationCode;                // OperationCode
    QGeoCoordinate location;              // Location [lat, lon]
    int operationIssueTypeId;             // OperationIssueTypeId (nullable in JSON)
    QString operationState;               // OperationState (BLOCKED, ACTIVE, etc.)
    int operationIssueSolutionTypeId;     // OperationIssueSolutionTypeId (nullable)
    QString estimatedArrival;             // EstimatedArrival (ISO8601 string, nullable)
    QString note;                         // Note (nullable)
    QString reportedAt;                   // ReportedAt (ISO8601 string)
    QString solvedAt;                     // SolvedAt (ISO8601 string, nullable)
    bool isDeleted;                       // IsDeleted
    QString createdAt;                    // CreatedAt (ISO8601 string)
    QString updatedAt;                    // UpdatedAt (ISO8601 string)

    // Helper to determine badge type
    QString getBadgeType() const {
        if (operationState == "BLOCKED") return "NEW";
        if (operationState == "ACTIVE") return "UPDATED";
        return "NEW"; // fallback
    }

    // Helper to determine accordion variant
    QString getVariantType() const {
        if (operationState == "BLOCKED") return "Urgent";
        if (operationState == "ACTIVE") return "Success";
        return "Warning"; // fallback
    }
};

#endif // TRUCKNOTIFICATION_H
