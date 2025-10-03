#include "TrackModel.h"

TrackModel::TrackModel(QObject *parent)
    : BaseTrackModel(parent)
{}

int TrackModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;

    return m_tracks.size();
}

QVariant TrackModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid()) return {};
    if (index.row() < 0 || index.row() >= m_tracks.size()) return {};

    const auto& track = m_tracks[index.row()];
    switch (role) {
    case CodeRole: return track.code;
    case EntityRole: return track.entity;
    case PosRole: return QVariant::fromValue(track.pos);
    case CogRole: return track.cog;
    case SourceNameRole: return track.sourceName;
    case TimeRole: return track.time;
    case TrackUidRole: return track.trackUid;
    case TrackNumberRole: return track.trackNumber;
    case VelRole: return QVariant::fromValue(track.vel);
    case StateRole: return track.state;
    default: return {};
    }
}

QHash<int, QByteArray> TrackModel::roleNames() const
{
    return {
        { CodeRole, "code" },
        { EntityRole, "entity" },
        { PosRole, "pos" },
        { CogRole, "cog" },
        { SourceNameRole, "sourceName" },
        { TimeRole, "time" },
        { TrackUidRole, "trackUid" },
        { TrackNumberRole, "trackNumber" },
        { VelRole, "vel" },
        { StateRole, "state" },
    };
}

Qt::ItemFlags TrackModel::flags(const QModelIndex &index) const
{
    if (!index.isValid())
        return Qt::NoItemFlags;

    return Qt::ItemIsSelectable;
}

QVector<Track> &TrackModel::tracks()
{
    return m_tracks;
}

void TrackModel::set(const QVector<Track> &tracks)
{

    beginResetModel();
    m_tracks = tracks;
    endResetModel();
}

void TrackModel::upsert(const QVector<Track> &tracks)
{
    QSet<QString> seen;

    // Update existing track or insert it
    for (const auto& track : tracks) {
        seen.insert(track.code);
        auto it = m_upsertMap.find(track.code);

        if (it != m_upsertMap.end()) {
            // Update track
            const int row = it.value();

            QVector<int> changed = diffRoles(m_tracks[row], track);
            if (!changed.empty()) {
                m_tracks[row] = track;
                const QModelIndex idx = index(row);
                emit dataChanged(idx, idx, changed);
            }
        } else {
            // Insert track
            const int row = m_tracks.size();

            beginInsertRows({}, row, row);
            m_tracks.append(track);
            m_upsertMap.insert(track.code, row);
            endInsertRows();
        }
    }

    // Remove stale tracks
    bool removed = false;
    for (int row = m_tracks.size() - 1; row >= 0; row--) {
        const auto& track = m_tracks[row];
        if (!seen.contains(track.code)) {
            beginRemoveRows({}, row, row);
            m_upsertMap.remove(track.code);
            m_tracks.removeAt(row);
            endRemoveRows();
            removed = true;
        }
    }

    // Rebuild map if removed tracks. This is because the indices are now shifted.
    if (removed) {
        m_upsertMap.clear();
        m_upsertMap.reserve(m_tracks.size());
        for (int row = 0; row < m_tracks.size(); row++) {
            m_upsertMap.insert(m_tracks[row].code, row);
        }
    }
}

QVector<int> TrackModel::diffRoles(const Track &a, const Track &b) const
{
    QVector<int> roles;

    if (a.code != b.code) roles << CodeRole;
    if (a.entity != b.entity) roles << EntityRole;
    if (a.sourceName != b.sourceName) roles << SourceNameRole;
    if (a.trackUid != b.trackUid) roles << TrackUidRole;
    if (a.trackNumber != b.trackNumber) roles << TrackNumberRole;
    if (!almostEqual(a.vel, b.vel)) roles << VelRole;
    if (!almostEqual(a.pos, b.pos)) roles << PosRole;
    if (!qFuzzyCompare(a.cog, b.cog)) roles << CogRole;
    if (a.time != b.time) roles << TimeRole;
    if (a.state != b.state) roles << StateRole;

    return roles;
}

void TrackModel::clear()
{
    beginResetModel();
    m_tracks.clear();
    endResetModel();
}
