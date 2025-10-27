#ifndef TRACKMODEL_H
#define TRACKMODEL_H

#include "BaseTrackModel.h"
#include <QVector>
#include <QHash>
#include <QQmlEngine>
#include <entities/Track.h>
#include "ModelHelper.h"

class TrackModel : public BaseTrackModel<Track>
{
    Q_OBJECT
    QML_ELEMENT

public:
    explicit TrackModel(QObject *parent = nullptr);

    enum Roles {
        PosRole = Qt::UserRole + 1,
        CogRole,
        TimeRole,
        VelRole,
        StateRole,
        CodeRole,
        EntityRole,
        SourceNameRole,
        NameRole,
        TrackUidRole,
        TrackNumberRole,
        UidForHistoryRole,
        HistoryRole,
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

    Q_INVOKABLE QQmlPropertyMap* getEditableTrack(int index);

    Q_INVOKABLE void clear();

    Q_INVOKABLE QVariant getRoleData(int idx, int role) const;

    static QVariant historyToVariant(const QVector<HistoryPoint>& hist) {
        QVariantList out;
        out.reserve(hist.size());
        for (const auto& hp : hist) {
            // array compatti e cache-friendly: [lat, lon, alt, time]
            QVariantList tuple;
            tuple.reserve(4);
            tuple << hp.lat << hp.lon << hp.alt << static_cast<double>(hp.time);
            out.push_back(tuple);
        }
        return out;
    }

signals:
    void historyPayloadArrived(const QString& topic, const QString& uid);
private:
    QVector<Track> m_tracks;
    QHash<QString, int> m_upsertMap;
};

#endif // TRACKMODEL_H
