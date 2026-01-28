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

    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(bool initialLoadComplete READ initialLoadComplete NOTIFY initialLoadCompleteChanged)

public:
    explicit TruckNotificationModel(QObject *parent = nullptr);

    enum Roles {
        IdRole = Qt::UserRole + 1,
        EnvelopeIdRole,
        UserIdRole,
        OperationIdRole,
        OperationCodeRole,
        LocationRole,
        IssueTypeRole,
        OperationStateRole,
        SolutionTypeRole,
        EstimatedArrivalRole,
        NoteRole,
        ReportedAtRole,
        SolvedAtRole,
        CreatedAtRole,
        TimestampRole,
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
    bool initialLoadComplete() const { return m_initialLoadComplete; }
    void setInitialLoadComplete(bool complete);

    // Data access
    QVector<TruckNotification> &notifications();

    // Data manipulation
    void set(const QVector<TruckNotification> &notifications);
    void upsert(const QVector<TruckNotification> &notifications);

    // Invokable methods for QML
    Q_INVOKABLE void removeNotification(const QString& id);
    Q_INVOKABLE void clearAll();
    Q_INVOKABLE QQmlPropertyMap* getEditableNotification(int index);

signals:
    void countChanged();
    void stateCountsChanged();
    void initialLoadCompleteChanged();

private:
    QVector<int> diffRoles(const TruckNotification &a, const TruckNotification &b) const;

    QVector<TruckNotification> m_notifications;
    QHash<QString, int> m_upsertMap;
    QSet<QString> m_deletedIds;
    QPointer<ModelHelper> m_helper;
    bool m_initialLoadComplete = false;
};

#endif // TRUCKNOTIFICATIONMODEL_H
