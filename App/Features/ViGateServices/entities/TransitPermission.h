#pragma once
#include <QString>

struct TransitPermission {
    QString uidCode;
    QString auth;
    QString authCode;
    QString authMessage;
    int permissionId = 0;
    QString permissionType;
    QString ownerType;
    int vehicleId = 0;
    QString vehiclePlate;
    int peopleId = 0;
    QString peopleFullname;
    QString peopleBirthdayDate;
    QString peopleBirthdayPlace;
    int companyId = 0;
    QString companyFullname;
    QString companyCity;
    QString companyType;
};
