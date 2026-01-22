#ifndef HTTP_AIS_PARSER_H
#define HTTP_AIS_PARSER_H

#include "interfaces/IMessageParser.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QGeoCoordinate>
#include <entities/Track.h>
#include <entities/Velocity.h>
#include <QtMath>

class HttpAisParser : public IMessageParser<Track>
{
public:
    QVector<Track> parse(const QByteArray& message) override
    {
        QJsonParseError err;
        QJsonDocument doc = QJsonDocument::fromJson(message, &err);
        if (err.error != QJsonParseError::NoError || !doc.isArray()) {
            return {};
        }

        QVector<Track> tracks;
        QJsonArray arr = doc.array();
        tracks.reserve(arr.size()); // performance

        for (const QJsonValue& item : arr)
        {
            if (!item.isObject()) continue;
            QJsonObject wrapper = item.toObject();

            if (!wrapper.contains("AIS") || !wrapper["AIS"].isObject()) continue;

            QJsonObject ais = wrapper["AIS"].toObject();

            Track t;

            t.trackUid = QString::number(ais.value("MMSI").toVariant().toLongLong());
            t.uidForHistory = t.trackUid;      // manteniamo coerenza col parser MQTT
            t.name = ais.value("NAME").toString();
            t.code = ais.value("CALLSIGN").toString();
            t.entity = "AIS";
            t.sourceName = ais.value("SRC").toString();

            double lat = ais.value("LATITUDE").toDouble();
            double lon = ais.value("LONGITUDE").toDouble();
            t.pos = QGeoCoordinate(lat, lon);

            double speed = ais.value("SPEED").toDouble();   // in nodi?
            double course = ais.value("COURSE").toDouble(); // gradi

            t.cog = course;

            double rad = qDegreesToRadians(course);
            double vx = speed * qSin(rad);
            double vy = speed * qCos(rad);

            t.vel = Velocity(vx, vy, 0);
            t.state = QString::number(ais.value("NAVSTAT").toInt());
            t.time = parseTimestamp(ais.value("TIMESTAMP").toString());
            t.trackNumber = ais.value("NAME").toString().section('_', -1).toInt();   // non hai l'equivalente nel JSON AIS

            tracks.append(t);
        }
        return tracks;
    }

private:
    int parseTimestamp(const QString& ts)
    {
        // es: "2025-12-05 10:48:00 UTC"
        QDateTime dt = QDateTime::fromString(ts, "yyyy-MM-dd HH:mm:ss 'UTC'");
        dt.setTimeSpec(Qt::UTC);
        if (!dt.isValid()) return 0;
        return dt.toSecsSinceEpoch();
    }
};

#endif // HTTP_AIS_PARSER_H
