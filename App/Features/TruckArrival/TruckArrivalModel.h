#pragma once

#include <QAbstractListModel>
#include <QDateTime>
#include <QQmlEngine>

struct TruckArrival{
    QString id;
    QString shipName;
    QDateTime arrivalTime;
    int truckCount;
};

class TruckArrivalModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    enum Roles {
        IdRole = Qt::UserRole + 1,
        ShipNameRole,
        ArrivalTimeRole,
        TruckCountRole
    };

    explicit TruckArrivalModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    //Data manipulation
    void setArrivals(const QVector<TruckArrival> &arrivals);
    void clear();

signals:
    void countChanged();

private:
    QVector<TruckArrival> m_arrivals;
};

