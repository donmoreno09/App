#ifndef BASETRACK_H
#define BASETRACK_H

#include <QString>
#include <QGeoCoordinate>

class BaseTrack
{
public:
    QGeoCoordinate pos;       // pos:          tuple(x, y, z)
    double cog;               // cog:          number
    int time;                 // time:         number
    int state;                // state:        number
    QGeoCoordinate vel;       // vel:          tuple(x, y, z)
};

#endif // BASETRACK_H
