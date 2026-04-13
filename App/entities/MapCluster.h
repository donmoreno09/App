#ifndef MAPCLUSTER_H
#define MAPCLUSTER_H

#include <QGeoCoordinate>
#include <QString>
#include <QVariantList>

class MapCluster
{
public:
    QString sourceName;
    QGeoCoordinate pos;
    int count = 0;
    QVariantList items;
};

#endif // MAPCLUSTER_H
