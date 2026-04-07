#include "ClusterModel.h"

#include <cmath>
#include <QSet>

ClusterModel::ClusterModel(QObject *parent)
    : QAbstractListModel(parent)
{}

int ClusterModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;

    return m_clusters.size();
}

QVariant ClusterModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid())
        return {};

    if (index.row() < 0 || index.row() >= m_clusters.size())
        return {};

    const MapCluster &cluster = m_clusters[index.row()];

    switch (role) {
    case PosRole:
        return QVariant::fromValue(cluster.pos);
    case SourceNameRole:
        return cluster.sourceName;
    case CountRole:
        return cluster.count;
    case ItemsRole:
        return cluster.items;
    default:
        return {};
    }
}

QHash<int, QByteArray> ClusterModel::roleNames() const
{
    return {
        { PosRole, "pos" },
        { SourceNameRole, "sourceName" },
        { CountRole, "count" },
        { ItemsRole, "items" },
    };
}

Qt::ItemFlags ClusterModel::flags(const QModelIndex &index) const
{
    if (!index.isValid())
        return Qt::NoItemFlags;

    return Qt::ItemIsSelectable;
}

const QVector<MapCluster> &ClusterModel::clusters() const
{
    return m_clusters;
}

void ClusterModel::set(const QVector<MapCluster> &clusters)
{
    beginResetModel();
    m_clusters = clusters;
    endResetModel();
}

void ClusterModel::upsert(const QVector<MapCluster> &clusters)
{
    QSet<QString> seen;
    seen.reserve(clusters.size());

    for (const MapCluster &cluster : clusters) {
        seen.insert(clusterKey(cluster));
    }

    for (int row = m_clusters.size() - 1; row >= 0; --row) {
        if (!seen.contains(clusterKey(m_clusters[row]))) {
            beginRemoveRows({}, row, row);
            m_clusters.removeAt(row);
            endRemoveRows();
        }
    }

    m_upsertMap.clear();
    m_upsertMap.reserve(m_clusters.size());
    for (int row = 0; row < m_clusters.size(); ++row) {
        m_upsertMap.insert(clusterKey(m_clusters[row]), row);
    }

    for (const MapCluster &cluster : clusters) {
        const QString key = clusterKey(cluster);
        auto it = m_upsertMap.find(key);

        if (it != m_upsertMap.end()) {
            const int row = it.value();
            const QVector<int> changed = diffRoles(m_clusters[row], cluster);
            if (!changed.isEmpty()) {
                m_clusters[row] = cluster;
                const QModelIndex idx = index(row);
                emit dataChanged(idx, idx, changed);
            }
        } else {
            const int row = m_clusters.size();
            beginInsertRows({}, row, row);
            m_clusters.append(cluster);
            m_upsertMap.insert(key, row);
            endInsertRows();
        }
    }
}

void ClusterModel::clear()
{
    set({});
}

QString ClusterModel::clusterKey(const MapCluster &cluster) const
{
    // Best-effort identity to keep cluster delegates stable across refreshes.
    return QStringLiteral("%1|%2|%3|%4")
        .arg(cluster.sourceName)
        .arg(QString::number(cluster.pos.latitude(), 'f', 5))
        .arg(QString::number(cluster.pos.longitude(), 'f', 5))
        .arg(QString::number(cluster.pos.altitude(), 'f', 1));
}

QVector<int> ClusterModel::diffRoles(const MapCluster &current, const MapCluster &next) const
{
    QVector<int> roles;

    const auto almostEqual = [](double a, double b) {
        return std::abs(a - b) < 1e-6;
    };

    const bool positionChanged =
        !almostEqual(current.pos.latitude(), next.pos.latitude()) ||
        !almostEqual(current.pos.longitude(), next.pos.longitude()) ||
        !almostEqual(current.pos.altitude(), next.pos.altitude());

    if (positionChanged) roles << PosRole;
    if (current.sourceName != next.sourceName) roles << SourceNameRole;
    if (current.count != next.count) roles << CountRole;
    if (current.items != next.items) roles << ItemsRole;

    return roles;
}
