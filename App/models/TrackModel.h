#ifndef TRACKMODEL_H
#define TRACKMODEL_H

#include "BaseTrackModel.h"
#include <QVector>
#include <QHash>
#include <QQmlEngine>
#include <entities/Track.h>

class TrackModel : public BaseTrackModel<Track>
{
    Q_OBJECT
    QML_ELEMENT

public:
    explicit TrackModel(QObject *parent = nullptr);

    enum Roles {
        CodeRole = Qt::UserRole + 1,
        EntityRole,
        PosRole,
        CogRole,
        SourceNameRole,
        TimeRole,
        TrackUidRole,
        TrackNumberRole,
        VelRole,
        StateRole,
    };

    Q_ENUM(Roles)

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    QHash<int, QByteArray> roleNames() const override;

    Qt::ItemFlags flags(const QModelIndex &index) const override;

    QVector<Track> &tracks();

    void set(const QVector<Track> &tracks) override;

    void upsert(const QVector<Track> &tracks) override;

    QVector<int> diffRoles(const Track &a, const Track &b) const override;

    Q_INVOKABLE void clear();

private:
    QVector<Track> m_tracks;
    QHash<QString, int> m_upsertMap;
};

#endif // TRACKMODEL_H
