#ifndef TRACK_H
#define TRACK_H

#include <QString>
#include <QGeoCoordinate>

class Track
{
public:
    QString code;             // code:         string
    QString entity;           // entity:       string
    QGeoCoordinate pos;       // pos:          tuple(x, y, z)
    double cog;               // cog:          number
    QString sourceName;       // source_name:  string
    int time;                 // time:         number
    int state;                // state:        number
    QString trackUid;         // track_uid:    string
    int trackNumber;          // tracknumber:  number
    QGeoCoordinate vel;       // vel:          tuple(x, y, z)
};

#endif // TRACK_H
