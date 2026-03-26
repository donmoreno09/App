#include "PermissionManager.h"
#include "QDebug"

PermissionManager::PermissionManager(QObject* parent)
    : QObject(parent) {}

bool PermissionManager::hasPermission(const QString& permission) const
{
    return m_permissions.contains(permission);
}

bool PermissionManager::hasRole(const QString& role) const
{
    return m_role == role;
}

bool PermissionManager::hasAnyPermission(const QStringList& permissions) const
{
    for (const auto& p : permissions) {
        if (m_permissions.contains(p))
            return true;
    }
    return false;
}

void PermissionManager::loadFromSession(const QString& role, const QStringList& permissions)
{
    m_role = role;
    m_permissions = QSet<QString>(permissions.begin(), permissions.end());

    qDebug() << "Role loaded:" << m_role;

    qDebug() << "Permissions loaded:";
    for (const auto& perm : m_permissions)
        qDebug() << perm;

    ++m_revision;
    emit permissionsChanged();
}

void PermissionManager::clear()
{
    m_role.clear();
    m_permissions.clear();
    ++m_revision;
    emit permissionsChanged();
}
