#include "AlertZoneNotificationModel.h"
#include <QDebug>

AlertZoneNotificationModel::AlertZoneNotificationModel(QObject *parent)
    : QAbstractListModel(parent), m_helper(new ModelHelper(this))
{}

int AlertZoneNotificationModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) return 0;

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
    case AlertZoneRole: {
        QVariantMap map;
        map["id"] = notif.alertZone.id;
        map["label"] = notif.alertZone.label;
        map["severity"] = notif.alertZone.severity;
        map["active"] = notif.alertZone.active;

        QVariantMap layersMap;
        for (auto it = notif.alertZone.layers.begin(); it != notif.alertZone.layers.end(); ++it) {
            layersMap[it.key()] = it.value();
        }
        map["layers"] = layersMap;

        QVariantMap geometryMap;
        geometryMap["shapeTypeId"] = notif.alertZone.geometry.shapeTypeId;
        geometryMap["surface"] = notif.alertZone.geometry.surface;
        geometryMap["height"] = notif.alertZone.geometry.height;
        geometryMap["radiusA"] = notif.alertZone.geometry.radiusA;
        geometryMap["radiusB"] = notif.alertZone.geometry.radiusB;
        geometryMap["coordinate"] = QVariantMap{
            {"x", notif.alertZone.geometry.coordinate.x()},
            {"y", notif.alertZone.geometry.coordinate.y()}
        };
        QVariantList coordsList;
        for (const auto& coord : notif.alertZone.geometry.coordinates) {
            coordsList.append(QVariantMap{{"x", coord.x()}, {"y", coord.y()}});
        }
        geometryMap["coordinates"] = coordsList;
        map["geometry"] = geometryMap;

        return map;
    }
    case TrackDataRole: {
        QVariantMap map;
        map["id"] = notif.trackData.id;
        map["operationCode"] = notif.trackData.operationCode;
        map["position"] = QVariant::fromValue(notif.trackData.position);
        map["velocity"] = notif.trackData.velocity;
        map["cog"] = notif.trackData.cog;
        map["time"] = notif.trackData.time;
        map["state"] = notif.trackData.state;
        map["isDeleted"] = notif.trackData.isDeleted;
        map["createdAt"] = notif.trackData.createdAt;
        map["updatedAt"] = notif.trackData.updatedAt;
        return map;
    }
    case TrackTypeRole: return notif.trackType;
    case TopicRole: return notif.topic;
    case StatusRole: return notif.status;
    case DetectedAtRole: return notif.detectedAt;
    case SentAtRole: return notif.sentAt;
    case CreatedAtRole: return notif.createdAt;
    case UpdatedAtRole: return notif.updatedAt;
    case IsReadRole: return notif.isRead;
    case IsDeletedRole: return notif.isDeleted;
    default: return {};
    }
}

QHash<int, QByteArray> AlertZoneNotificationModel::roleNames() const
{
    return {
            { IdRole, "id" },
            { UserIdRole, "userId" },
            { AlertZoneRole, "alertZone" },
            { TrackDataRole, "trackData" },
            { TrackTypeRole, "trackType" },
            { TopicRole, "topic" },
            { StatusRole, "status" },
            { DetectedAtRole, "detectedAt" },
            { SentAtRole, "sentAt" },
            { CreatedAtRole, "createdAt" },
            { UpdatedAtRole, "updatedAt" },
            { IsReadRole, "isRead" },
            { IsDeletedRole, "isDeleted" },
            };
}

Qt::ItemFlags AlertZoneNotificationModel::flags(const QModelIndex &index) const
{
    if (!index.isValid()) return Qt::NoItemFlags;

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
    if (notifications.isEmpty()) { return; }

    qDebug() << "[AlertZoneNotificationModel] upsert() called with" << notifications.size() << "notifications";

    bool countChanged = false;

    for (const auto& notif : notifications) {
        qDebug() << "[AlertZoneNotificationModel] Processing notification: " << notif.id;

        // Skip if already deleted
        if (m_deletedIds.contains(notif.id)) {
            qWarning() << "[AlertZoneNotificationModel] Skipping deleted notification: " << notif.id;
            continue;
        }

        auto it = m_upsertMap.find(notif.id);

        if (it != m_upsertMap.end()) {
            const int row = it.value();

            QVector<int> changed = diffRoles(m_notifications[row], notif);
            if (!changed.empty()) {
                m_notifications[row] = notif;
                const QModelIndex idx = index(row);
                emit dataChanged(idx, idx, changed);
                qDebug() << "[AlertZoneNotificationModel] Updated notification at row" << row;
            } else {
                qDebug() << "[AlertZoneNotificationModel] No changes for notification at row" << row;
            }
        } else {
            // Insert new notification
            const int row = m_notifications.size();

            beginInsertRows({}, row, row);
            m_notifications.append(notif);
            m_upsertMap.insert(notif.id, row);
            endInsertRows();
            countChanged = true;

            qDebug() << "[AlertZoneNotificationModel] Inserted new notification at row" << row;
        }
    }

    if (countChanged) {
        qDebug() << "[AlertZoneNotificationModel] Count changed to:" << m_notifications.size();
        emit this->countChanged();
    }
}

QVector<int> AlertZoneNotificationModel::diffRoles(const AlertZoneNotification &a, const AlertZoneNotification &b) const
{
    QVector<int> roles;

    if (a.id != b.id) roles << IdRole;
    if (a.userId != b.userId) roles << UserIdRole;
    if (a.alertZone.id != b.alertZone.id || a.alertZone.label != b.alertZone.label ||
        a.alertZone.severity != b.alertZone.severity) roles << AlertZoneRole;
    if (a.trackData.id != b.trackData.id || a.trackData.operationCode != b.trackData.operationCode ||
        a.trackData.position != b.trackData.position) roles << TrackDataRole;
    if (a.trackType != b.trackType) roles << TrackTypeRole;
    if (a.topic != b.topic) roles << TopicRole;
    if (a.status != b.status) roles << StatusRole;
    if (a.detectedAt != b.detectedAt) roles << DetectedAtRole;
    if (a.sentAt != b.sentAt) roles << SentAtRole;
    if (a.createdAt != b.createdAt) roles << CreatedAtRole;
    if (a.updatedAt != b.updatedAt) roles << UpdatedAtRole;
    if (a.isRead != b.isRead) roles << IsReadRole;
    if (a.isDeleted != b.isDeleted) roles << IsDeletedRole;

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

QVariantMap AlertZoneNotificationModel::getEditableNotification(int index)
{
    return m_helper->data(index);
}

void AlertZoneNotificationModel::setInitialLoadComplete(bool complete)
{
    if (m_initialLoadComplete != complete) {
        m_initialLoadComplete = complete;
        emit initialLoadCompleteChanged();
        qDebug() << "[TruckNotificationModel] Initial load complete set to:" << complete;
    }
}
