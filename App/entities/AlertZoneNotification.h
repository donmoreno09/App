#ifndef ALERTZONENOTIFICATION_H
#define ALERTZONENOTIFICATION_H

#include <QString>
#include <QGeoCoordinate>
#include <QDateTime>

/**
 * @brief AlertZoneNotification entity
 *
 * Represents a Control Room Alert Zone Intrusion notification (EventType 2).
 * Received from backend SignalR hub when a track enters an alert zone.
 */
class AlertZoneNotification
{
public:
    QString id;                    // Notification ID (from envelope)
    QString userId;                // User ID (from envelope)

    // Payload fields (parse from Payload JSON string)
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

    // Helper to determine badge type
    QString getBadgeType() const {
        return "ALERT"; // AlertZone notifications are always alerts
    }

    // Helper to determine accordion variant
    QString getVariantType() const {
        return "Urgent"; // AlertZone intrusions are urgent
    }
};

#endif // ALERTZONENOTIFICATION_H
