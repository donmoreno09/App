#ifndef ALERTZONENOTIFICATION_H
#define ALERTZONENOTIFICATION_H

#include <QString>
#include <QDateTime>
#include "AlertZone.h"
#include "NotificationTrackData.h"

class AlertZoneNotification
{
public:
    QString id;
    QString userId;

    // Nested objects
    AlertZone alertZone;
    NotificationTrackData trackData;

    // Payload-level fields
    QString trackType;
    QString topic;
    QString detectedAt;

    // Envelope-level fields
    int status = 0;
    QString sentAt;
    QString createdAt;
    QString updatedAt;

    // Local metadata
    bool isRead = false;
    bool isDeleted = false;
};

#endif // ALERTZONENOTIFICATION_H
