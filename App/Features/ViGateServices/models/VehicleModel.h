#pragma once
#include <QAbstractListModel>
#include <QDateTime>
#include <QStringList>
#include <QQmlEngine>
#include <QJsonArray>

struct VehicleEntry {
    int idGate;
    QDateTime startDate;
    QStringList plates;
    QString direction;
};

class VehicleModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT

public:
    enum Roles {
        IdGateRole = Qt::UserRole + 1,
        StartDateRole,
        PlateRole,
        DirectionRole
    };

    explicit VehicleModel(QObject* parent = nullptr);

    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void clear();
    Q_INVOKABLE void setData(const QJsonArray& vehiclesArray);

private:
    QList<VehicleEntry> m_entries;
};
