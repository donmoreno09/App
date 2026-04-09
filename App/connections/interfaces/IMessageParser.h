#ifndef IMESSAGEPARSER_H
#define IMESSAGEPARSER_H

#include <QVariantList>
#include <QByteArray>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QGeoCoordinate>

#include <entities/ClusteredPayload.h>
#include <entities/MapCluster.h>

class IBaseMessageParser {
public:
    virtual ~IBaseMessageParser() = default;
};

template <class TResult>
class IMessageParser : public IBaseMessageParser {
public:
    virtual ~IMessageParser() = default;
    virtual TResult parse(const QByteArray& message) = 0;

protected:
    // Some store coordinate order in (lon, lat) instead of (lat, lon)
    // Use swap to use (lon, lat).
    static QGeoCoordinate parseCoordinateArray(const QJsonArray &arr, bool swap = false) {
        QGeoCoordinate coord;
        coord.setLatitude(arr[swap ? 1 : 0].toDouble());
        coord.setLongitude(arr[swap ? 0 : 1].toDouble());
        coord.setAltitude(arr[2].toDouble());
        return coord;
    }

    template <class T, class F>
    static ClusteredPayload<T> parseClusteredPayload(const QJsonDocument &doc, F parseTracksFn) {
        if (doc.isArray()) {
            ClusteredPayload<T> payload;
            payload.hasTracks = true;
            payload.tracks = parseTracksFn(doc.array());
            return payload;
        }

        if (!doc.isObject()) {
            return {};
        }

        const QJsonObject root = doc.object();

        ClusteredPayload<T> payload;
        payload.hasClusters = root.contains("clusters");
        payload.hasTracks = root.contains("tracks");

        if (payload.hasClusters) {
            payload.clusters = parseClusters(root.value("clusters").toArray());
        }

        if (payload.hasTracks) {
            payload.tracks = parseTracksFn(root.value("tracks").toArray());
        }

        return payload;
    }

private:
    static QVector<MapCluster> parseClusters(const QJsonArray &clustersArray) {
        QVector<MapCluster> clusters;
        clusters.reserve(clustersArray.size());

        for (const QJsonValue &value : clustersArray) {
            if (!value.isObject())
                continue;

            const QJsonObject clusterObject = value.toObject();
            const QJsonArray posArray = clusterObject.value("pos").toArray();
            if (posArray.size() < 2)
                continue;

            MapCluster cluster;
            cluster.sourceName = clusterObject.value("source_name").toString();
            cluster.pos = parseCoordinateArray(posArray);
            cluster.count = clusterObject.value("count").toInt();
            cluster.items = clusterObject.value("items").toArray().toVariantList();

            clusters.append(cluster);
        }

        return clusters;
    }
};

#endif // IMESSAGEPARSER_H
