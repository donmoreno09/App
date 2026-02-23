#ifndef BASETRACKMODEL_H
#define BASETRACKMODEL_H

#include <QAbstractListModel>
#include <QVector>
#include <QGeoCoordinate>
#include "ModelHelper.h"
#include "entities/Velocity.h"
#include "entities/HistoryPoint.h"

template <class T>
class BaseTrackModel : public QAbstractListModel
{
public:
    explicit BaseTrackModel(QObject *parent = nullptr)
        : QAbstractListModel(parent), m_helper(new ModelHelper(this))
    {}

    virtual void set(const QVector<T> &data) = 0;

    virtual void upsert(const QVector<T> &data) = 0;

    virtual QVector<int> diffRoles(const T &a, const T &b) const = 0;

protected:
    QPointer<ModelHelper> m_helper;

    // TODO: Export this method to a more general utility namespace
    bool almostEqual(const QGeoCoordinate &a, const QGeoCoordinate &b, double tolerance = 1e-6) const
    {
        return std::abs(a.latitude()  - b.latitude())  < tolerance &&
               std::abs(a.longitude() - b.longitude()) < tolerance &&
               std::abs(a.altitude() - b.altitude()) < tolerance;
    }

    // TODO: Export this method to a more general utility namespace
    bool almostEqual(const Velocity &a, const Velocity &b, double epsilon = 1e-3) const
    {
        return std::abs(a.vx - b.vx) < epsilon &&
               std::abs(a.vy - b.vy) < epsilon &&
               std::abs(a.vz - b.vz) < epsilon;
    }

    static QVariant historyToVariant(const QVector<HistoryPoint>& hist) {
        QVariantList out;
        out.reserve(hist.size());
        for (const auto& hp : hist) {
            // array compatti e cache-friendly: [lat, lon, alt, time]
            QVariantList tuple;
            tuple.reserve(4);
            tuple << hp.lat << hp.lon << hp.alt << static_cast<double>(hp.time);
            out.push_back(tuple);
        }
        return out;
    }
};

#endif // BASETRACKMODEL_H
