#include "TruckNotificationModel.h"
#include <QDebug>

TruckNotificationModel::TruckNotificationModel(QObject *parent)
    : QAbstractListModel(parent), m_helper(new ModelHelper(this))
{
}

int TruckNotificationModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;

    return m_notifications.size();
}

QVariant TruckNotificationModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid()) return {};
    if (index.row() < 0 || index.row() >= m_notifications.size()) return {};

    const auto& notif = m_notifications[index.row()];

    switch (role) {
    case IdRole: return notif.id;
    case UserIdRole: return notif.userId;
    case OperationIdRole: return notif.operationId;
    case OperationCodeRole: return notif.operationCode;
    case LocationRole: return QVariant::fromValue(notif.location);
    case OperationIssueTypeIdRole: return notif.operationIssueTypeId;
    case OperationStateRole: return notif.operationState;
    case OperationIssueSolutionTypeIdRole: return notif.operationIssueSolutionTypeId;
    case EstimatedArrivalRole: return notif.estimatedArrival;
    case NoteRole: return notif.note;
    case ReportedAtRole: return notif.reportedAt;
    case SolvedAtRole: return notif.solvedAt;
    case IsDeletedRole: return notif.isDeleted;
    case CreatedAtRole: return notif.createdAt;
    case UpdatedAtRole: return notif.updatedAt;
    case BadgeTypeRole: return notif.getBadgeType();
    case VariantTypeRole: return notif.getVariantType();
    default: return {};
    }
}

QHash<int, QByteArray> TruckNotificationModel::roleNames() const
{
    return {
        { IdRole, "id" },
        { UserIdRole, "userId" },
        { OperationIdRole, "operationId" },
        { OperationCodeRole, "operationCode" },
        { LocationRole, "location" },
        { OperationIssueTypeIdRole, "operationIssueTypeId" },
        { OperationStateRole, "operationState" },
        { OperationIssueSolutionTypeIdRole, "operationIssueSolutionTypeId" },
        { EstimatedArrivalRole, "estimatedArrival" },
        { NoteRole, "note" },
        { ReportedAtRole, "reportedAt" },
        { SolvedAtRole, "solvedAt" },
        { IsDeletedRole, "isDeleted" },
        { CreatedAtRole, "createdAt" },
        { UpdatedAtRole, "updatedAt" },
        { BadgeTypeRole, "badgeType" },
        { VariantTypeRole, "variantType" }
    };
}

Qt::ItemFlags TruckNotificationModel::flags(const QModelIndex &index) const
{
    if (!index.isValid())
        return Qt::NoItemFlags;

    return Qt::ItemIsSelectable;
}

QVector<TruckNotification> &TruckNotificationModel::notifications()
{
    return m_notifications;
}

void TruckNotificationModel::set(const QVector<TruckNotification> &notifications)
{
    beginResetModel();
    m_notifications = notifications;
    m_upsertMap.clear();
    for (int i = 0; i < m_notifications.size(); ++i) {
        m_upsertMap.insert(m_notifications[i].id, i);
    }
    endResetModel();
}

void TruckNotificationModel::upsert(const QVector<TruckNotification> &notifications)
{
    QSet<QString> seen;

    // Update existing notification or insert it
    for (const auto& notif : notifications) {
        seen.insert(notif.id);
        auto it = m_upsertMap.find(notif.id);

        if (it != m_upsertMap.end()) {
            // Update notification
            const int row = it.value();

            QVector<int> changed = diffRoles(m_notifications[row], notif);
            if (!changed.empty()) {
                m_notifications[row] = notif;
                const QModelIndex idx = index(row);
                emit dataChanged(idx, idx, changed);
            }
        } else {
            // Insert notification
            const int row = m_notifications.size();

            beginInsertRows({}, row, row);
            m_notifications.append(notif);
            m_upsertMap.insert(notif.id, row);
            endInsertRows();
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
}

QVector<int> TruckNotificationModel::diffRoles(const TruckNotification &a, const TruckNotification &b) const
{
    QVector<int> roles;

    if (a.id != b.id) roles << IdRole;
    if (a.userId != b.userId) roles << UserIdRole;
    if (a.operationId != b.operationId) roles << OperationIdRole;
    if (a.operationCode != b.operationCode) roles << OperationCodeRole;
    if (a.location != b.location) roles << LocationRole;
    if (a.operationIssueTypeId != b.operationIssueTypeId) roles << OperationIssueTypeIdRole;
    if (a.operationState != b.operationState) roles << OperationStateRole;
    if (a.operationIssueSolutionTypeId != b.operationIssueSolutionTypeId) roles << OperationIssueSolutionTypeIdRole;
    if (a.estimatedArrival != b.estimatedArrival) roles << EstimatedArrivalRole;
    if (a.note != b.note) roles << NoteRole;
    if (a.reportedAt != b.reportedAt) roles << ReportedAtRole;
    if (a.solvedAt != b.solvedAt) roles << SolvedAtRole;
    if (a.isDeleted != b.isDeleted) roles << IsDeletedRole;
    if (a.createdAt != b.createdAt) roles << CreatedAtRole;
    if (a.updatedAt != b.updatedAt) roles << UpdatedAtRole;

    // Check helper roles
    if (a.getBadgeType() != b.getBadgeType()) roles << BadgeTypeRole;
    if (a.getVariantType() != b.getVariantType()) roles << VariantTypeRole;

    return roles;
}

int TruckNotificationModel::countByState(const QString &state) const
{
    int count = 0;
    for (const auto& notif : m_notifications) {
        if (notif.operationState == state) {
            count++;
        }
    }
    return count;
}

void TruckNotificationModel::removeNotification(const QString &id)
{
    auto it = m_upsertMap.find(id);
    if (it == m_upsertMap.end()) {
        qWarning() << "[TruckNotificationModel] Cannot remove notification with id:" << id << "- not found";
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

    qDebug() << "[TruckNotificationModel] Removed notification:" << id;
}

void TruckNotificationModel::clearAll()
{
    beginResetModel();
    m_notifications.clear();
    m_upsertMap.clear();
    endResetModel();
    qDebug() << "[TruckNotificationModel] Cleared all notifications";
}

QQmlPropertyMap *TruckNotificationModel::getEditableNotification(int index)
{
    return m_helper->map(index);
}
