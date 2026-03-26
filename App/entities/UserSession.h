#ifndef USERSESSION_H
#define USERSESSION_H

#include <QString>
#include <QStringList>
#include <QJsonObject>
#include <QJsonArray>
#include "IPersistable.h"

class UserSession : public IPersistable
{
public:
    QString userId;
    QString firstName;
    QString lastName;
    QString email;
    QString role;
    QStringList permissions;

    QString displayName() const { return (firstName + " " + lastName).trimmed(); }
    bool isValid() const { return !userId.isEmpty(); }

    void clear()
    {
        userId.clear();
        firstName.clear();
        lastName.clear();
        email.clear();
        role.clear();
        permissions.clear();
    }

    QJsonObject toJson() const override
    {
        QJsonObject obj;
        obj["id"] = userId;
        obj["firstName"] = firstName;
        obj["lastName"] = lastName;
        obj["email"] = email;
        obj["role"] = role;
        obj["permissions"] = QJsonArray::fromStringList(permissions);
        return obj;
    }

    void fromJson(const QJsonObject& obj) override
    {
        userId = obj["id"].toString();
        firstName = obj["firstName"].toString();
        lastName = obj["lastName"].toString();
        email = obj["email"].toString();
        role = obj["role"].toString();

        permissions.clear();
        for (const auto& v : obj["permissions"].toArray())
            if (v.isString()) permissions.append(v.toString());
    }
};

#endif // USERSESSION_H
