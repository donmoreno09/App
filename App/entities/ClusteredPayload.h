#ifndef CLUSTEREDPAYLOAD_H
#define CLUSTEREDPAYLOAD_H

#include <QVector>

#include "MapCluster.h"

template <class T>
struct ClusteredPayload
{
    bool hasClusters = false;
    bool hasTracks = false;
    QVector<MapCluster> clusters;
    QVector<T> tracks;

    bool isEmpty() const
    {
        return !hasClusters && !hasTracks;
    }
};

#endif // CLUSTEREDPAYLOAD_H
