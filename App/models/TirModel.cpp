#include "TirModel.h"
#include <QSet>

TirModel::TirModel(QObject *parent)
    : BaseTrackModel(parent)
{}

int TirModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;

    return m_tirs.size();
}

QVariant TirModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid()) return {};
    if (index.row() < 0 || index.row() >= m_tirs.size()) return {};

    const auto& tir = m_tirs[index.row()];
    switch (role) {
    case OperationCodeRole: return tir.operationCode;
    case PosRole: return QVariant::fromValue(tir.pos);
    case CogRole: return tir.cog;
    case TimeRole: return tir.time;
    case VelRole: return tir.vel;
    case StateRole: return tir.state;
    case SourceNameRole: return tir.sourceName;
    case NameRole: return tir.name;
    default: return {};
    }
}

QHash<int, QByteArray> TirModel::roleNames() const
{
    return {
        { NameRole, "name"},
        { OperationCodeRole, "operationCode" },
        { PosRole, "pos" },
        { CogRole, "cog" },
        { TimeRole, "time" },
        { VelRole, "vel" },
        { StateRole, "state" },
        { SourceNameRole, "sourceName"}
    };
}

Qt::ItemFlags TirModel::flags(const QModelIndex &index) const
{
    if (!index.isValid())
        return Qt::NoItemFlags;

    return Qt::ItemIsSelectable;
}

QVector<Tir> &TirModel::tirs()
{
    return m_tirs;
}

void TirModel::set(const QVector<Tir> &tirs)
{
    beginResetModel();
    m_tirs = tirs;
    endResetModel();
}

void TirModel::upsert(const QVector<Tir> &tirs)
{
    QSet<QString> seen;

    // Update existing tir or insert it
    for (const auto& tir : tirs) {
        seen.insert(tir.operationCode);
        auto it = m_upsertMap.find(tir.operationCode);

        if (it != m_upsertMap.end()) {
            // Update tir
            const int row = it.value();

            QVector<int> changed = diffRoles(m_tirs[row], tir);
            if (!changed.empty()) {
                m_tirs[row] = tir;
                const QModelIndex idx = index(row);
                emit dataChanged(idx, idx, changed);
            }
        } else {
            // Insert tir
            const int row = m_tirs.size();

            beginInsertRows({}, row, row);
            m_tirs.append(tir);
            m_upsertMap.insert(tir.operationCode, row);
            endInsertRows();
        }
    }

    // Remove stale tirs
    bool removed = false;
    for (int row = m_tirs.size() - 1; row >= 0; row--) {
        const auto& tir = m_tirs[row];
        if (!seen.contains(tir.operationCode)) {
            beginRemoveRows({}, row, row);
            m_upsertMap.remove(tir.operationCode);
            m_tirs.removeAt(row);
            endRemoveRows();
            removed = true;
        }
    }

    // Rebuild map if removed tirs. This is because the indices are now shifted.
    if (removed) {
        m_upsertMap.clear();
        m_upsertMap.reserve(m_tirs.size());
        for (int row = 0; row < m_tirs.size(); row++) {
            m_upsertMap.insert(m_tirs[row].operationCode, row);
        }
    }
}

QVector<int> TirModel::diffRoles(const Tir &a, const Tir &b) const
{
    QVector<int> roles;

    if (a.operationCode != b.operationCode) roles << OperationCodeRole;
    if (!qFuzzyCompare(a.vel, b.vel)) roles << VelRole;
    if (!almostEqual(a.pos, b.pos)) roles << PosRole;
    if (!qFuzzyCompare(a.cog, b.cog)) roles << CogRole;
    if (a.time != b.time) roles << TimeRole;
    if (a.state != b.state) roles << StateRole;
    if (a.sourceName != b.sourceName) roles << SourceNameRole;
    if (a.name != b.name) roles << NameRole;

    return roles;
}

QQmlPropertyMap *TirModel::getEditableTir(int index)
{
    return m_helper->map(index);
}

void TirModel::clear()
{
    beginResetModel();
    m_tirs.clear();
    endResetModel();
}

QVariant TirModel::getRoleData(int idx, int role) const
{
    return data(index(idx), role);
}
