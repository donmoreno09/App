#ifndef ALERTZONENOTIFICATIONMODEL_H
#define ALERTZONENOTIFICATIONMODEL_H

#include <QAbstractListModel>
#include <QVector>
#include <QHash>
#include <QPointer>
#include <QQmlEngine>
#include <entities/AlertZoneNotification.h>
#include "ModelHelper.h"

/**
 * @brief AlertZoneNotificationModel
 *
 * Model for Alert Zone Intrusion notifications (EventType 2).
 * Follows the same pattern as TruckNotificationModel for consistency.
 */
class AlertZoneNotificationModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    explicit AlertZoneNotificationModel(QObject *parent = nullptr);

    enum Roles {
        IdRole = Qt::UserRole + 1,
        UserIdRole,
        TitleRole,
        MessageRole,
        TimestampRole,
        TrackIdRole,
        TrackNameRole,
        AlertZoneIdRole,
        AlertZoneNameRole,
        LocationRole,
        CreatedAtRole,
        IsReadRole,
        IsDeletedRole,
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

    // Data access
    QVector<AlertZoneNotification> &notifications();

    // Data manipulation
    void set(const QVector<AlertZoneNotification> &notifications);
    void upsert(const QVector<AlertZoneNotification> &notifications);

    // Invokable methods for QML
    Q_INVOKABLE void removeNotification(const QString& id);
    Q_INVOKABLE void clearAll();
    Q_INVOKABLE QQmlPropertyMap* getEditableNotification(int index);

signals:
    void countChanged();

private:
    QVector<int> diffRoles(const AlertZoneNotification &a, const AlertZoneNotification &b) const;

    QVector<AlertZoneNotification> m_notifications;
    QHash<QString, int> m_upsertMap; // id -> row index
    QSet<QString> m_deletedIds;
    QPointer<ModelHelper> m_helper;
};

#endif // ALERTZONENOTIFICATIONMODEL_H
