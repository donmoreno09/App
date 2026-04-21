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
    case UidForHistoryRole: return tir.uidForHistory;
    case HistoryRole: return historyToVariant(tir.history);
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
        { SourceNameRole, "sourceName" },
        { UidForHistoryRole, "uidForHistory" },
        { HistoryRole, "history" },
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

void TirModel::upsert(const QVector<Tir>& tirs)
{
    // 1) Build "seen" keys from incoming payload
    QSet<QString> seen;
    for (const auto& tir : tirs) {
        seen.insert(tir.operationCode);
    }

    // 2) Remove stale items (not present anymore)
    for (int row = m_tirs.size() - 1; row >= 0; --row) {
        if (!seen.contains(m_tirs[row].operationCode)) {
            beginRemoveRows({}, row, row);
            m_tirs.removeAt(row);
            endRemoveRows();
        }
    }

    // 3) Rebuild upsert map (indices may have shifted)
    m_upsertMap.clear();
    m_upsertMap.reserve(m_tirs.size());
    for (int row = 0; row < m_tirs.size(); ++row) {
        m_upsertMap.insert(m_tirs[row].operationCode, row);
    }

    // 4) Upsert (update existing, or insert new)
    for (const auto& tir : tirs) {
        auto it = m_upsertMap.find(tir.operationCode);

        if (it != m_upsertMap.end()) {
            const int row = it.value();

            const bool historyWasEmpty = m_tirs[row].history.isEmpty();
            const bool historyWillBeNonEmpty = !tir.history.isEmpty();

            QVector<int> changed = diffRoles(m_tirs[row], tir);
            if (!changed.empty()) {
                m_tirs[row] = tir;
                const QModelIndex idx = index(row);
                emit dataChanged(idx, idx, changed);
            }

            if (historyWasEmpty && historyWillBeNonEmpty) {
                emit historyPayloadArrived(
                    m_tirs[row].sourceName,
                    m_tirs[row].uidForHistory
                );
            }

        } else {
            const int row = m_tirs.size();

            beginInsertRows({}, row, row);
            m_tirs.append(tir);
            m_upsertMap.insert(tir.operationCode, row);
            endInsertRows();

            if (!tir.history.isEmpty()) {
                emit historyPayloadArrived(tir.sourceName, tir.uidForHistory);
            }
        }
    }
}

QVector<int> TirModel::diffRoles(const Tir& a, const Tir& b) const
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
    if (a.uidForHistory != b.uidForHistory) roles << UidForHistoryRole;

    // History: check if it's updated (size or last timestamp changed)
    const int asz   = a.history.size();
    const int bsz   = b.history.size();
    const int alast = asz ? a.history.constLast().time : std::numeric_limits<int>::min();
    const int blast = bsz ? b.history.constLast().time : std::numeric_limits<int>::min();

    if (asz != bsz || alast != blast)
        roles << HistoryRole;

    return roles;
}

QQmlPropertyMap *TirModel::getEditableTir(int index)
{
    return m_helper->map(index, 0, {}, true);
}

void TirModel::clear()
{
    beginResetModel();
    m_tirs.clear();
    endResetModel();
}

void TirModel::clearHistory(const QString& uid)
{
    for (int row = 0; row < m_tirs.size(); ++row) {
        if (m_tirs[row].uidForHistory == uid && !m_tirs[row].history.isEmpty()) {
            m_tirs[row].history.clear();
            const QModelIndex idx = index(row);
            emit dataChanged(idx, idx, { HistoryRole });
        }
    }
}

QVariant TirModel::getRoleData(int idx, int role) const
{
    return data(index(idx), role);
}
