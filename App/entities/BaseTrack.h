#ifndef BASETRACK_H
#define BASETRACK_H

#include <QString>
#include <QGeoCoordinate>

class BaseTrack
{
public:
    QString uidForHistory;    // uidForHistory:   number
    QGeoCoordinate pos;       // pos:               tuple(x, y, z)
    double cog;               // cog:               number
    int time;                 // time:              number
    QString state;            // state:             string
    QString name;             // name:              string
};

#endif // BASETRACK_H
