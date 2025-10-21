#include "PedestrianModel.h"
#include <QJsonArray>
#include <QJsonObject>
#include <QDebug>

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
        if (!value.isObject()) {
            qWarning() << "PedestrianModel: Skipping non-object entry";
            continue;
        }

        QJsonObject obj = value.toObject();
        PedestrianEntry entry;

        entry.idGate = obj.value("idGate").toInt(0);

        QString dateStr = obj.value("startDate").toString();
        entry.startDate = QDateTime::fromString(dateStr, Qt::ISODate);

        if (!entry.startDate.isValid()) {
            qWarning() << "PedestrianModel: Invalid date format:" << dateStr;
            entry.startDate = QDateTime::currentDateTime();
        }

        entry.direction = obj.value("direction").toString("UNKNOWN");
        if (entry.direction != "IN" && entry.direction != "OUT") {
            qWarning() << "PedestrianModel: Unknown direction:" << entry.direction;
        }

        m_entries.append(entry);
    }

    qDebug() << "PedestrianModel: Loaded" << m_entries.size() << "pedestrians";
    endResetModel();
}
