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
        BadgeTypeRole,      // Helper: "NEW" or "UPDATED"
        VariantTypeRole     // Helper: "Urgent", "Success", "Warning"
    };

    Q_ENUM(Roles)

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;
    Qt::ItemFlags flags(const QModelIndex &index) const override;

    QVector<TruckNotification> &notifications();

    void set(const QVector<TruckNotification> &notifications);
    void upsert(const QVector<TruckNotification> &notifications);
    QVector<int> diffRoles(const TruckNotification &a, const TruckNotification &b) const;

    Q_INVOKABLE int countByState(const QString& state) const;
    Q_INVOKABLE void removeNotification(const QString& id);
    Q_INVOKABLE void clearAll();
    Q_INVOKABLE QQmlPropertyMap* getEditableNotification(int index);

private:
    QVector<TruckNotification> m_notifications;
    QHash<QString, int> m_upsertMap; // id -> row index
    QPointer<ModelHelper> m_helper;
};

#endif // TRUCKNOTIFICATIONMODEL_H
