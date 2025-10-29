#ifndef COORDINATESMODEL_H
#define COORDINATESMODEL_H

#include <QList>
#include <QVector2D>
#include <QAbstractListModel>
#include <QQmlEngine>
#include <QPointer>
#include "ModelHelper.h"

class CoordinatesModel : public QAbstractListModel {
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("Intended for internal use only. See PoiModel.")

public:
    enum { LatitudeRole = Qt::UserRole + 1, LongitudeRole };
    explicit CoordinatesModel(QObject* parent = nullptr) : QAbstractListModel(parent), m_helper(new ModelHelper(this)) {}

    int rowCount(const QModelIndex&) const override { return m_points.size(); }

    QVariant data(const QModelIndex& index, int role) const override {
        if (!index.isValid() || index.row() < 0 || index.row() >= m_points.size()) return {};

        const auto& point = m_points[index.row()];
        if (role == LatitudeRole) return point.y();
        if (role == LongitudeRole) return point.x();
        return {};
    }

    QHash<int,QByteArray> roleNames() const override {
        return { {LatitudeRole,"latitude"}, {LongitudeRole,"longitude"} };
    }

    bool setData(const QModelIndex &index, const QVariant &value, int role) override {
        if (!index.isValid() || index.row() < 0 || index.row() >= m_points.size()) return {};

        auto& point = m_points[index.row()];
        bool changed = false;

        if (role == LatitudeRole) {
            const auto lat = value.toFloat();
            if (!qFuzzyCompare(point.y(), lat)) {
                point.setY(lat);
                changed = true;
            }
        }
        if (role == LongitudeRole) {
            const auto lon = value.toFloat();
            if (!qFuzzyCompare(point.x(), lon)) {
                point.setX(lon);
                changed = true;
            }
        }

        if (changed) emit dataChanged(index, index, { role });
        return changed;
    }

    Q_INVOKABLE QQmlPropertyMap* getEditablePoint(int index) {
        return m_helper->map(index, 0);
    }

    void setPoints(const QList<QVector2D>& points) {
        beginResetModel();
        m_points = points;
        endResetModel();
    }

private:
    QList<QVector2D> m_points;
    QPointer<ModelHelper> m_helper;
};

#endif // COORDINATESMODEL_H
