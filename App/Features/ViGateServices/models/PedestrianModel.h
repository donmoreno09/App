#pragma once
#include <QAbstractListModel>
#include <QDateTime>
#include <QQmlEngine>
#include <QJsonArray>

struct PedestrianEntry {
    int idGate;
    QDateTime startDate;
    QString direction;
};

class PedestrianModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT

public:
    enum Roles {
        IdGateRole = Qt::UserRole + 1,
        StartDateRole,
        DirectionRole
    };

    explicit PedestrianModel(QObject* parent = nullptr);

    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void clear();
    Q_INVOKABLE void setData(const QJsonArray& pedestriansArray);

private:
    QList<PedestrianEntry> m_entries;
};
