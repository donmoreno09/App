#ifndef VESSELMODEL_H
#define VESSELMODEL_H

#include <QVector>
#include <QHash>
#include <QQmlEngine>
#include "BaseTrackModel.h"
#include "entities/Vessel.h"

class VesselModel : public BaseTrackModel<Vessel>
{
    Q_OBJECT
    QML_ELEMENT

public:
    explicit VesselModel(QObject *parent = nullptr);

    enum Roles {
        // Inherited from BaseTrack
        PosRole = Qt::UserRole + 1,
        CogRole,
        TimeRole,
        StateRole,
        NameRole,
        UidForHistoryRole,
        HistoryRole,

        // Vessel-specific
        MmsiRole,
        HeadingRole,
        SpeedRole,
        ARole,
        BRole,
        CRole,
        DRole,

        // Derived (computed, not stored)
        ShipLengthRole,
        ShipWidthRole,
        HasDimensionsRole,
        DisplayHeadingRole,
    };

    Q_ENUM(Roles)

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    QHash<int, QByteArray> roleNames() const override;

    Qt::ItemFlags flags(const QModelIndex &index) const override;

    QVector<Vessel> &vessels();

    void set(const QVector<Vessel> &vessels) override;

    void upsert(const QVector<Vessel> &vessels) override;

    QVector<int> diffRoles(const Vessel &a, const Vessel &b) const override;

    Q_INVOKABLE QQmlPropertyMap* getEditableVessel(int index);

    Q_INVOKABLE void clear();

    Q_INVOKABLE QVariant getRoleData(int idx, int role) const;

signals:
    void historyPayloadArrived(const QString& topic, const QString& uid);

private:
    QVector<Vessel> m_vessels;
    QHash<QString, int> m_upsertMap;
};

#endif // VESSELMODEL_H
