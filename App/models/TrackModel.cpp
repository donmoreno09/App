#include "TrackModel.h"

TrackModel::TrackModel(QObject *parent)
    : QAbstractListModel(parent)
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
    case SourceNameRole: return track.sourceName;
    case TimeRole: return track.time;
    case TrackUidRole: return track.trackUid;
    case TrackNumberRole: return track.trackNumber;
    case VelRole: return QVariant::fromValue(track.vel);
    default: return {};
    }
}

QHash<int, QByteArray> TrackModel::roleNames() const
{
    return {
        { CodeRole, "code" },
        { EntityRole, "entity" },
        { PosRole, "pos" },
        { SourceNameRole, "sourceName" },
        { TimeRole, "time" },
        { TrackUidRole, "trackUid" },
        { TrackNumberRole, "trackNumber" },
        { VelRole, "vel" },
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

void TrackModel::setTracks(const QVector<Track> &tracks)
{
    m_tracks = tracks;
}

void TrackModel::clear()
{
    m_tracks.clear();
}
