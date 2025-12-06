#ifndef ALERTZONENOTIFICATION_H
#define ALERTZONENOTIFICATION_H

#include <QString>
#include <QGeoCoordinate>
#include <QDateTime>

class AlertZoneNotification
{
public:
    QString id;
    QString userId;

    QString title;                 // Title of notification
    QString message;               // Message content
    QString timestamp;             // ISO8601 timestamp
    QString trackId;               // Track that triggered the alert (if available)
    QString trackName;             // Track name (if available)
    QString alertZoneId;           // Alert zone ID (if available)
    QString alertZoneName;         // Alert zone name (if available)
    QGeoCoordinate location;       // Location where intrusion occurred (if available)

    // Metadata
    QString createdAt;             // When notification was created
    bool isRead;                   // Whether user has read the notification
    bool isDeleted;                // Local deletion flag
};

#endif // ALERTZONENOTIFICATION_H
