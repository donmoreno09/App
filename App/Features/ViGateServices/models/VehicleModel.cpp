#include "VehicleModel.h"
#include <QJsonArray>
#include <QJsonObject>

VehicleModel::VehicleModel(QObject* parent)
    : QAbstractListModel(parent)
{}

int VehicleModel::rowCount(const QModelIndex& parent) const
{
    if (parent.isValid()) return 0;
    return m_entries.size();
}

QVariant VehicleModel::data(const QModelIndex& index, int role) const
{
    if (!index.isValid() || index.row() >= m_entries.size())
        return {};

    const auto& entry = m_entries.at(index.row());

    switch (role) {
    case IdGateRole:
        return entry.idGate;
    case StartDateRole:
        return entry.startDate.toString("dd/MM/yyyy HH:mm");
    case PlateRole:
        return entry.plates.isEmpty() ? QString() : entry.plates.first();
    case DirectionRole:
        return entry.direction;
    default:
        return {};
    }
}

QHash<int, QByteArray> VehicleModel::roleNames() const
{
    return {
        {IdGateRole, "idGate"},
        {StartDateRole, "startDate"},
        {PlateRole, "plate"},
        {DirectionRole, "direction"}
    };
}

void VehicleModel::clear()
{
    beginResetModel();
    m_entries.clear();
    endResetModel();
}

void VehicleModel::setData(const QJsonArray& vehiclesArray)
{
    beginResetModel();
    m_entries.clear();

    for (const auto& value : vehiclesArray) {
        if (!value.isObject()) continue;

        QJsonObject obj = value.toObject();
        VehicleEntry entry;

        entry.idGate = obj["idGate"].toInt();
        entry.startDate = QDateTime::fromString(obj["startDate"].toString(), Qt::ISODate);

        // Parse arrays
        for (const auto& plate : obj["plate"].toArray())
            entry.plates.append(plate.toString());

        entry.direction = obj["direction"].toString();

        m_entries.append(entry);
    }

    endResetModel();
}
