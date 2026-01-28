#ifndef TRUCKNOTIFICATION_H
#define TRUCKNOTIFICATION_H

#include <QString>
#include <QGeoCoordinate>
#include <QDateTime>

class TruckNotification
{
public:
    QString id;                           // IssueId (was Id in old payload)
    QString envelopeId;                   // Envelope Id (backend deletion ID)
    QString userId;                       // UserId
    QString operationId;                  // OperationId
    QString operationCode;                // OperationCode
    QGeoCoordinate location;              // Location {Longitude, Latitude}
    QString issueType;                    // IssueType (string: "INCIDENT", "DELAY", etc.)
    QString operationState;               // OperationState (BLOCKED, ACTIVE, etc.)
    QString solutionType;                 // SolutionType (string: "OTHER", "RESCHEDULED", etc.)
    QString estimatedArrival;             // EstimatedArrival (ISO8601 string, nullable)
    QString note;                         // Note (nullable)
    QString reportedAt;                   // ReportedAt (ISO8601 string)
    QString solvedAt;                     // SolvedAt (ISO8601 string, nullable)
    QString createdAt;                    // CreatedAt (ISO8601 string)
    QString timestamp;                    // Timestamp (ISO8601 string)
};

#endif // TRUCKNOTIFICATION_H
