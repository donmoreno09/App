#ifndef NOTIFICATIONTRACKDATA_H
#define NOTIFICATIONTRACKDATA_H

#include <QString>
#include <QJsonObject>
#include <QJsonArray>
#include <QGeoCoordinate>

struct NotificationTrackData {
    QString id;
    QString trackingId;
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

        // Id for TIR, Iridess_uid for AIS/DOC-SPACE
        data.id = obj.contains("Id") ? obj["Id"].toString() : obj["Iridess_uid"].toString();

        // Track_uid for AIS/DOC-SPACE, OperationCode for TIR
        if (obj.contains("Track_uid") && !obj["Track_uid"].toString().isEmpty()) {
            data.trackingId = obj["Track_uid"].toString();
        } else {
            data.trackingId = obj["OperationCode"].toString();
        }

        // Parse position from Pos array [lat, lon] or [lat, lon, altitude]
        QJsonArray posArray = obj["Pos"].toArray();
        if (posArray.size() >= 2) {
            double lat = posArray[0].toDouble();
            double lon = posArray[1].toDouble();
            data.position = QGeoCoordinate(lat, lon);
            if (posArray.size() >= 3) {
                data.position.setAltitude(posArray[2].toDouble());
            }
        }

        data.velocity = obj["Vel"].toDouble();
        data.cog = obj["Cog"].toDouble();
        data.time = obj["Time"].toVariant().toLongLong();
        data.state = obj["State"].toString();
        data.isDeleted = obj["IsDeleted"].toBool();
        data.createdAt = obj["CreatedAt"].toString();
        data.updatedAt = obj["UpdatedAt"].toString();

        return data;
    }
};

#endif // NOTIFICATIONTRACKDATA_H
