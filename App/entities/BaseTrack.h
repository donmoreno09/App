#ifndef BASETRACK_H
#define BASETRACK_H

#include <QString>
#include <QVector>
#include <QGeoCoordinate>
#include "HistoryPoint.h"

class BaseTrack
{
public:
    QString uidForHistory;          // uidForHistory:  number
    QVector<HistoryPoint> history;  // history:        vector<HistoryPoint>
    QGeoCoordinate pos;             // pos:            tuple(x, y, z)
    double cog;                     // cog:            number
    int time;                       // time:           number
    QString state;                  // state:          string
    QString name;                   // name:           string
};

#endif // BASETRACK_H
