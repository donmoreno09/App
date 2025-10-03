#include "BaseTrackModel.h"

template<class T>
BaseTrackModel<T>::BaseTrackModel(QObject *parent)
    : QAbstractListModel(parent)
{}

template<class T>
bool BaseTrackModel<T>::almostEqual(const QGeoCoordinate &a, const QGeoCoordinate &b, double tolerance) const
{
    return std::abs(a.latitude()  - b.latitude())  < tolerance &&
           std::abs(a.longitude() - b.longitude()) < tolerance &&
           std::abs(a.altitude() - b.altitude()) < tolerance;
}
