#ifndef TRACK_H
#define TRACK_H

#include <QString>
#include <QGeoCoordinate>
#include "BaseTrack.h"
#include "Velocity.h"
#include "HistoryPoint.h"

class Track : public BaseTrack
{
public:
    QString code;                   // code:         string
    QString entity;                 // entity:       string
    QString sourceName;             // source_name:  string
    QString trackUid;               // track_uid:    string
    int trackNumber;                // tracknumber:  number
    Velocity vel;                   // vel:          tuple(x, y, z)
    QVector<HistoryPoint> history;  // history:      vector<HistoryPoint>
};

#endif // TRACK_H
