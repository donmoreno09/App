#ifndef NOTIFICATIONTRACKDATA_H
#define NOTIFICATIONTRACKDATA_H

#include <QString>
#include <QJsonObject>
#include <QJsonArray>
#include <QGeoCoordinate>

struct NotificationTrackData {
    QString id;
    QString operationCode;
    QGeoCoordinate position;
    double velocity = 0;
    double cog = 0;
    qint64 time = 0;
    QString state;
    bool isDeleted = false;
    QString createdAt;
    QString updatedAt;

    static NotificationTrackData fromJson(const QJsonObject& obj) {
        NotificationTrackData data;

        data.id = obj.contains("Id") ? obj["Id"].toString() : obj["id"].toString();
        data.operationCode = obj.contains("OperationCode") ? obj["OperationCode"].toString() : obj["operationCode"].toString();

        // Parse position from Pos array [lat, lon]
        QJsonArray posArray = obj.contains("Pos") ? obj["Pos"].toArray() : obj["pos"].toArray();
        if (posArray.size() >= 2) {
            double lat = posArray[0].toDouble();
            double lon = posArray[1].toDouble();
            data.position = QGeoCoordinate(lat, lon);
        }

        data.velocity = obj.contains("Vel") ? obj["Vel"].toDouble() : obj["vel"].toDouble();
        data.cog = obj.contains("Cog") ? obj["Cog"].toDouble() : obj["cog"].toDouble();
        data.time = obj.contains("Time") ? obj["Time"].toVariant().toLongLong() : obj["time"].toVariant().toLongLong();
        data.state = obj.contains("State") ? obj["State"].toString() : obj["state"].toString();
        data.isDeleted = obj.contains("IsDeleted") ? obj["IsDeleted"].toBool() : obj["isDeleted"].toBool();
        data.createdAt = obj.contains("CreatedAt") ? obj["CreatedAt"].toString() : obj["createdAt"].toString();
        data.updatedAt = obj.contains("UpdatedAt") ? obj["UpdatedAt"].toString() : obj["updatedAt"].toString();

        return data;
    }
};

#endif // NOTIFICATIONTRACKDATA_H
