#ifndef TRUCKNOTIFICATIONMODEL_H
#define TRUCKNOTIFICATIONMODEL_H

#include <QAbstractListModel>
#include <QVector>
#include <QHash>
#include <QPointer>
#include <QQmlEngine>
#include <entities/TruckNotification.h>
#include "ModelHelper.h"

class TruckNotificationModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    // Expose count property for QML bindings
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    explicit TruckNotificationModel(QObject *parent = nullptr);

    enum Roles {
        IdRole = Qt::UserRole + 1,
        UserIdRole,
        OperationIdRole,
        OperationCodeRole,
        LocationRole,
        OperationIssueTypeIdRole,
        OperationStateRole,
        OperationIssueSolutionTypeIdRole,
        EstimatedArrivalRole,
        NoteRole,
        ReportedAtRole,
        SolvedAtRole,
        IsDeletedRole,
        CreatedAtRole,
        UpdatedAtRole,
        BadgeTypeRole,
        VariantTypeRole
    };

    Q_ENUM(Roles)

    // QAbstractListModel interface
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;
    Qt::ItemFlags flags(const QModelIndex &index) const override;

    // Property getters
    int count() const { return m_notifications.size(); }
    int blockedCount() const { return countByState("BLOCKED"); }
    int activeCount() const { return countByState("ACTIVE"); }
    int warningCount() const { return countByState("WARNING"); }

    // Data access
    QVector<TruckNotification> &notifications();

    // Data manipulation
    void set(const QVector<TruckNotification> &notifications);
    void upsert(const QVector<TruckNotification> &notifications);

    // Invokable methods for QML
    Q_INVOKABLE int countByState(const QString& state) const;
    Q_INVOKABLE void removeNotification(const QString& id);
    Q_INVOKABLE void clearAll();
    Q_INVOKABLE QQmlPropertyMap* getEditableNotification(int index);

signals:
    void countChanged();
    void stateCountsChanged();

private:
    QVector<int> diffRoles(const TruckNotification &a, const TruckNotification &b) const;

    QVector<TruckNotification> m_notifications;
    QHash<QString, int> m_upsertMap; // id -> row index
    QSet<QString> m_deletedIds;
    QPointer<ModelHelper> m_helper;
};

#endif // TRUCKNOTIFICATIONMODEL_H
