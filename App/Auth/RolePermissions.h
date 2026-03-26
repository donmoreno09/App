#pragma once

#include <QMap>
#include <QString>
#include <QStringList>

// Client-side role → permission mapping.
// Used until the backend sends granular permissions in the JWT.
// To remove: delete this file and update AuthManager::handleLoginResult().
namespace RolePermissions {

inline QStringList permissionsFor(const QString& role)
{
    static const QMap<QString, QStringList> map = {
        {
            "IPOS_CONTROL_ROOM_OPERATOR", {
                "track.read",
                "notification.read",
                "alertzone.read",
                "poi.read",
                "vigate.read",
            }
        },
        {
            "IPOS_CONTROL_ROOM_MANAGER", {
                "track.read",
                "notification.read",
                "alertzone.read",
                "alertzone.create",
                "alertzone.edit",
                "alertzone.delete",
                "poi.read",
                "poi.create",
                "poi.edit",
                "poi.delete",
                "vigate.read",
                "vigate.manage",
            }
        },
        {
            "IPOS_CONTROL_ROOM_ADMIN", {
                "track.read",
                "notification.read",
                "alertzone.read",
                "alertzone.create",
                "alertzone.edit",
                "alertzone.delete",
                "poi.read",
                "poi.create",
                "poi.edit",
                "poi.delete",
                "vigate.read",
                "vigate.manage",
                "settings.read",
                "settings.edit",
            }
        },
    };

    return map.value(role, {});
}

} // namespace RolePermissions
