/**
 * This file is currently in progress.
 */

#ifndef POIMODEL_H
#define POIMODEL_H

#include <QAbstractListModel>
#include <QVector>
#include <QQmlEngine>
#include "../entities/Poi.h"

class PoiModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT

public:
    explicit PoiModel(QObject *parent = nullptr);

    enum Roles {
        // Poi
        IdRole = Qt::UserRole + 1,
        LabelRole,
        LabelIdRole,
        LayerNameRole,
        TypeIdRole,
        TypeNameRole,
        CategoryIdRole,
        CategoryNameRole,
        HealthStatusIdRole,
        HealthStatusNameRole,
        OperationalStateIdRole,
        OperationalStateNameRole,
        // Geometry
        ShapeTypeIdRole,
        SurfaceRole,
        HeightRole,
        CoordinatesRole, // Perhaps this is better as a model?
        CoordinateRole,
        RadiusARole,
        RadiusBRole,
        // Details
        NoteRole
    };

    Q_ENUM(Roles)

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override;

    QHash<int, QByteArray> roleNames() const override;

    Qt::ItemFlags flags(const QModelIndex &index) const override;

private:
    QVector<Poi> m_pois;
};

#endif // POIMODEL_H
