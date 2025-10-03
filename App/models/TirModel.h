#ifndef TIRMODEL_H
#define TIRMODEL_H

#include "BaseTrackModel.h"
#include <QVector>
#include <QHash>
#include <QQmlEngine>
#include <entities/Tir.h>

class TirModel : public BaseTrackModel<Tir>
{
    Q_OBJECT
    QML_ELEMENT

public:
    explicit TirModel(QObject *parent = nullptr);

    enum Roles {
        OperationCodeRole = Qt::UserRole + 1,
        PosRole,
        CogRole,
        TimeRole,
        VelRole,
        StateRole,
    };

    Q_ENUM(Roles)

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    QHash<int, QByteArray> roleNames() const override;

    Qt::ItemFlags flags(const QModelIndex &index) const override;

    QVector<Tir> &tirs();

    void set(const QVector<Tir> &tirs) override;

    void upsert(const QVector<Tir> &tirs) override;

    QVector<int> diffRoles(const Tir &a, const Tir &b) const override;

    Q_INVOKABLE void clear();

private:
    QVector<Tir> m_tirs;
    QHash<QString, int> m_upsertMap;
};

#endif // TIRMODEL_H
