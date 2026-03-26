#ifndef ROLEPERMISSIONS_H
#define ROLEPERMISSIONS_H

#include <QMap>
#include <QString>
#include <QStringList>

// NOTE
// This is a client-side role permission mapping.
// Used until the backend sends granular permissions in the JWT.
// TO DO: delete this file and update AuthManager::handleLoginResult().

namespace RolePermissions {

inline QStringList permissionsFor(const QString& role)
{
    static const QMap<QString, QStringList> map = {
        {
            "IPOS_CONTROL_ROOM_OPERATOR", {
                "track.activate",
                "notification.read",
                "alertzone.read",
                "alertzone.create",
                "poi.read",
                "poi.create",
                "vigate.fetch",
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
                "vigate.fetch",
            }
        },
        {
            "IPOS_CONTROL_ROOM_ADMIN", {
                "track.activate",
                "notification.read",
                "alertzone.read",
                "alertzone.create",
                "alertzone.edit",
                "alertzone.delete",
                "poi.read",
                "poi.create",
                "poi.edit",
                "poi.delete",
                "vigate.fetch",
                "settings.read",
                "settings.edit",
            }
        },
    };

    return map.value(role, {});
}

}

#endif // ROLEPERMISSIONS_H
