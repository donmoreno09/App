#include "VehicleModel.h"
#include <QJsonArray>
#include <QJsonObject>
#include <QDebug>

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
        return entry.plates.join(", ");
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
        if (!value.isObject()) {
            qWarning() << "VehicleModel: Skipping non-object entry";
            continue;
        }

        QJsonObject obj = value.toObject();
        VehicleEntry entry;

        entry.idGate = obj.value("idGate").toInt(0);

        QString dateStr = obj.value("startDate").toString();
        entry.startDate = QDateTime::fromString(dateStr, Qt::ISODate);

        if (!entry.startDate.isValid()) {
            qWarning() << "VehicleModel: Invalid date format:" << dateStr;
            entry.startDate = QDateTime::currentDateTime(); // Fallback
        }

        QJsonArray plateArray = obj.value("plate").toArray();
        if (plateArray.isEmpty()) {
            qWarning() << "VehicleModel: Empty plate array for gate" << entry.idGate;
            entry.plates.append("N/A");
        } else {
            for (int i = 0; i < plateArray.size(); ++i) {
                QString plateStr = plateArray[i].toString().trimmed();
                if (!plateStr.isEmpty()) {
                    entry.plates.append(plateStr);
                }
            }
        }

        entry.direction = obj.value("direction").toString("UNKNOWN");
        if (entry.direction != "IN" && entry.direction != "OUT") {
            qWarning() << "VehicleModel: Unknown direction:" << entry.direction;
        }

        m_entries.append(entry);
    }

    qDebug() << "VehicleModel: Loaded" << m_entries.size() << "vehicles";
    endResetModel();
}
