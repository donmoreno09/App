#include "AlertZoneNotificationModel.h"
#include <QDebug>

AlertZoneNotificationModel::AlertZoneNotificationModel(QObject *parent)
    : QAbstractListModel(parent), m_helper(new ModelHelper(this))
{
}

int AlertZoneNotificationModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;

    return m_notifications.size();
}

QVariant AlertZoneNotificationModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid()) return {};
    if (index.row() < 0 || index.row() >= m_notifications.size()) return {};

    const auto& notif = m_notifications[index.row()];

    switch (role) {
    case IdRole: return notif.id;
    case UserIdRole: return notif.userId;
    case TitleRole: return notif.title;
    case MessageRole: return notif.message;
    case TimestampRole: return notif.timestamp;
    case TrackIdRole: return notif.trackId;
    case TrackNameRole: return notif.trackName;
    case AlertZoneIdRole: return notif.alertZoneId;
    case AlertZoneNameRole: return notif.alertZoneName;
    case LocationRole: return QVariant::fromValue(notif.location);
    case CreatedAtRole: return notif.createdAt;
    case IsReadRole: return notif.isRead;
    case IsDeletedRole: return notif.isDeleted;
    case BadgeTypeRole: return notif.getBadgeType();
    case VariantTypeRole: return notif.getVariantType();
    default: return {};
    }
}

QHash<int, QByteArray> AlertZoneNotificationModel::roleNames() const
{
    return {
        { IdRole, "id" },
        { UserIdRole, "userId" },
        { TitleRole, "title" },
        { MessageRole, "message" },
        { TimestampRole, "timestamp" },
        { TrackIdRole, "trackId" },
        { TrackNameRole, "trackName" },
        { AlertZoneIdRole, "alertZoneId" },
        { AlertZoneNameRole, "alertZoneName" },
        { LocationRole, "location" },
        { CreatedAtRole, "createdAt" },
        { IsReadRole, "isRead" },
        { IsDeletedRole, "isDeleted" },
        { BadgeTypeRole, "badgeType" },
        { VariantTypeRole, "variantType" }
    };
}

Qt::ItemFlags AlertZoneNotificationModel::flags(const QModelIndex &index) const
{
    if (!index.isValid())
        return Qt::NoItemFlags;

    return Qt::ItemIsSelectable;
}

QVector<AlertZoneNotification> &AlertZoneNotificationModel::notifications()
{
    return m_notifications;
}

void AlertZoneNotificationModel::set(const QVector<AlertZoneNotification> &notifications)
{
    beginResetModel();
    m_notifications = notifications;
    m_upsertMap.clear();
    for (int i = 0; i < m_notifications.size(); ++i) {
        m_upsertMap.insert(m_notifications[i].id, i);
    }
    endResetModel();
    emit countChanged();
}

void AlertZoneNotificationModel::upsert(const QVector<AlertZoneNotification> &notifications)
{
    QSet<QString> seen;
    bool countChanged = false;

    // Update existing notification or insert it
    for (const auto& notif : notifications) {
        if (m_deletedIds.contains(notif.id)) {
            continue;
        }

        seen.insert(notif.id);
        auto it = m_upsertMap.find(notif.id);

        if (it != m_upsertMap.end()) {
            // Update existing notification
            const int row = it.value();

            QVector<int> changed = diffRoles(m_notifications[row], notif);
            if (!changed.empty()) {
                m_notifications[row] = notif;
                const QModelIndex idx = index(row);
                emit dataChanged(idx, idx, changed);
            }
        } else {
            // Insert new notification
            const int row = m_notifications.size();

            beginInsertRows({}, row, row);
            m_notifications.append(notif);
            m_upsertMap.insert(notif.id, row);
            endInsertRows();
            countChanged = true;
        }
    }

    // Remove stale notifications (not in current batch)
    bool removed = false;
    for (int row = m_notifications.size() - 1; row >= 0; row--) {
        const auto& notif = m_notifications[row];
        if (!seen.contains(notif.id)) {
            beginRemoveRows({}, row, row);
            m_upsertMap.remove(notif.id);
            m_notifications.removeAt(row);
            endRemoveRows();
            removed = true;
            countChanged = true;
        }
    }

    // Rebuild map if removed notifications (indices shifted)
    if (removed) {
        m_upsertMap.clear();
        m_upsertMap.reserve(m_notifications.size());
        for (int row = 0; row < m_notifications.size(); row++) {
            m_upsertMap.insert(m_notifications[row].id, row);
        }
    }

    if (countChanged) {
        emit this->countChanged();
    }
}

QVector<int> AlertZoneNotificationModel::diffRoles(const AlertZoneNotification &a,
                                                   const AlertZoneNotification &b) const
{
    QVector<int> roles;

    if (a.id != b.id) roles << IdRole;
    if (a.userId != b.userId) roles << UserIdRole;
    if (a.title != b.title) roles << TitleRole;
    if (a.message != b.message) roles << MessageRole;
    if (a.timestamp != b.timestamp) roles << TimestampRole;
    if (a.trackId != b.trackId) roles << TrackIdRole;
    if (a.trackName != b.trackName) roles << TrackNameRole;
    if (a.alertZoneId != b.alertZoneId) roles << AlertZoneIdRole;
    if (a.alertZoneName != b.alertZoneName) roles << AlertZoneNameRole;
    if (a.location != b.location) roles << LocationRole;
    if (a.createdAt != b.createdAt) roles << CreatedAtRole;
    if (a.isRead != b.isRead) roles << IsReadRole;
    if (a.isDeleted != b.isDeleted) roles << IsDeletedRole;

    // Check helper roles
    if (a.getBadgeType() != b.getBadgeType()) roles << BadgeTypeRole;
    if (a.getVariantType() != b.getVariantType()) roles << VariantTypeRole;

    return roles;
}

void AlertZoneNotificationModel::removeNotification(const QString &id)
{
    m_deletedIds.insert(id);

    auto it = m_upsertMap.find(id);
    if (it == m_upsertMap.end()) {
        qWarning() << "[AlertZoneNotificationModel] Cannot remove notification with id:" << id << "- not found";
        return;
    }

    const int row = it.value();

    beginRemoveRows({}, row, row);
    m_upsertMap.remove(id);
    m_notifications.removeAt(row);
    endRemoveRows();

    // Rebuild map (indices shifted)
    m_upsertMap.clear();
    m_upsertMap.reserve(m_notifications.size());
    for (int i = 0; i < m_notifications.size(); i++) {
        m_upsertMap.insert(m_notifications[i].id, i);
    }

    emit countChanged();
    qDebug() << "[AlertZoneNotificationModel] Removed notification:" << id;
}

void AlertZoneNotificationModel::clearAll()
{
    if (m_notifications.isEmpty()) return;

    for (const auto& notif : m_notifications) {
        m_deletedIds.insert(notif.id);
    }

    beginResetModel();
    m_notifications.clear();
    m_upsertMap.clear();
    endResetModel();

    emit countChanged();
    qDebug() << "[AlertZoneNotificationModel] Cleared all notifications";
}

QQmlPropertyMap *AlertZoneNotificationModel::getEditableNotification(int index)
{
    return m_helper->map(index);
}
