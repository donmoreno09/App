#ifndef CLUSTERMODEL_H
#define CLUSTERMODEL_H

#include <QAbstractListModel>
#include <QHash>
#include <QQmlEngine>
#include <QVector>

#include "entities/MapCluster.h"

class ClusterModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT

public:
    explicit ClusterModel(QObject *parent = nullptr);

    enum Roles {
        PosRole = Qt::UserRole + 1,
        SourceNameRole,
        CountRole,
        ItemsRole,
    };

    Q_ENUM(Roles)

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;
    Qt::ItemFlags flags(const QModelIndex &index) const override;

    const QVector<MapCluster> &clusters() const;
    void set(const QVector<MapCluster> &clusters);
    void upsert(const QVector<MapCluster> &clusters);

    Q_INVOKABLE void clear();

private:
    QString clusterKey(const MapCluster &cluster) const;
    QVector<int> diffRoles(const MapCluster &current, const MapCluster &next) const;

    QVector<MapCluster> m_clusters;
    QHash<QString, int> m_upsertMap;
};

#endif // CLUSTERMODEL_H
