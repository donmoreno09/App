#include "PedestrianModel.h"
#include <QJsonArray>
#include <QJsonObject>

PedestrianModel::PedestrianModel(QObject* parent)
    : QAbstractListModel(parent)
{}

int PedestrianModel::rowCount(const QModelIndex& parent) const
{
    if (parent.isValid()) return 0;
    return m_entries.size();
}

QVariant PedestrianModel::data(const QModelIndex& index, int role) const
{
    if (!index.isValid() || index.row() >= m_entries.size())
        return {};

    const auto& entry = m_entries.at(index.row());

    switch (role) {
    case IdGateRole:
        return entry.idGate;
    case StartDateRole:
        return entry.startDate.toString("dd/MM/yyyy HH:mm");
    case DirectionRole:
        return entry.direction;
    default:
        return {};
    }
}

QHash<int, QByteArray> PedestrianModel::roleNames() const
{
    return {
        {IdGateRole, "idGate"},
        {StartDateRole, "startDate"},
        {DirectionRole, "direction"}
    };
}

void PedestrianModel::clear()
{
    beginResetModel();
    m_entries.clear();
    endResetModel();
}

void PedestrianModel::setData(const QJsonArray& pedestriansArray)
{
    beginResetModel();
    m_entries.clear();

    for (const auto& value : pedestriansArray) {
        if (!value.isObject()) continue;

        QJsonObject obj = value.toObject();
        PedestrianEntry entry;

        entry.idGate = obj["idGate"].toInt();
        entry.startDate = QDateTime::fromString(obj["startDate"].toString(), Qt::ISODate);
        entry.direction = obj["direction"].toString();

        m_entries.append(entry);
    }

    endResetModel();
}
