#ifndef BASETRACKMODEL_H
#define BASETRACKMODEL_H

#include <QAbstractListModel>
#include <QVector>
#include <QGeoCoordinate>

template <class T>
class BaseTrackModel : public QAbstractListModel
{
public:
    explicit BaseTrackModel(QObject *parent = nullptr)
        : QAbstractListModel(parent)
    {}

    virtual void set(const QVector<T> &data) = 0;

    virtual void upsert(const QVector<T> &data) = 0;

    virtual QVector<int> diffRoles(const T &a, const T &b) const = 0;

protected:
    // TODO: Export this method to a more general utility namespace
    bool almostEqual(const QGeoCoordinate &a, const QGeoCoordinate &b, double tolerance = 1e-6) const
    {
        return std::abs(a.latitude()  - b.latitude())  < tolerance &&
               std::abs(a.longitude() - b.longitude()) < tolerance &&
               std::abs(a.altitude() - b.altitude()) < tolerance;
    }
};

#endif // BASETRACKMODEL_H
