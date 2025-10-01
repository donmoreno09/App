#include "TruckArrivalModel.h"

TruckArrivalModel::TruckArrivalModel(QObject *parent) : QAbstractListModel(parent)
{
}

int TruckArrivalModel::rowCount(const QModelIndex &parent) const
{
    if(parent.isValid()) return 0;
    return m_arrivals.count();
}

QVariant TruckArrivalModel::data(const QModelIndex &index, int role) const
{
    if(!index.isValid() || index.row() >= m_arrivals.count())
        return QVariant();

    const TruckArrival &arrival = m_arrivals.at(index.row());

    switch(role) {
    case IdRole:
        return arrival.id;
    case ShipNameRole:
        return arrival.shipName;
    case ArrivalTimeRole:
        return arrival.arrivalTime;
    case TruckCountRole:
        return arrival.truckCount;
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> TruckArrivalModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[IdRole] = "id";
    roles[ShipNameRole] = "shipName";
    roles[ArrivalTimeRole] = "arrivalTime";
    roles[TruckCountRole] = "truckCount";
    return roles;
}

void TruckArrivalModel::setArrivals(const QVector<TruckArrival> &arrivals)
{
    beginResetModel();
    m_arrivals = arrivals;
    endResetModel();
    emit countChanged();
}

void TruckArrivalModel::clear()
{
    if(m_arrivals.isEmpty()) return;
    beginResetModel();
    m_arrivals.clear();
    endResetModel();
    emit countChanged();
}

