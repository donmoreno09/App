#pragma once
#include <QString>
#include <QDateTime>
#include "TransitInfo.h"
#include "TransitPermission.h"

struct TransitEntry {
    // Basic info
    QString transitId;
    QString gateName;
    QDateTime transitStartDate;
    QDateTime transitEndDate;
    QString transitStatus;

    // Lane info
    QString laneTypeId;
    QString laneStatusId;
    QString laneName;
    QString transitDirection;

    // Transit info (only for VEHICLE)
    TransitInfo transitInfo;
    bool hasTransitInfo = false;

    // Permission (first element only)
    TransitPermission permission;
    bool hasPermission = false;
};
