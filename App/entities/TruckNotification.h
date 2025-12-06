#ifndef TRUCKNOTIFICATION_H
#define TRUCKNOTIFICATION_H

#include <QString>
#include <QGeoCoordinate>
#include <QDateTime>

class TruckNotification
{
public:
    QString id;                           // Id
    QString envelopeId;                   // Envelope Id (backend deletion ID)
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
};

#endif // TRUCKNOTIFICATION_H
