#ifndef HTTP_VESSEL_PARSER_H
#define HTTP_VESSEL_PARSER_H

#include "interfaces/IMessageParser.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QGeoCoordinate>
#include <QDateTime>
#include <QTimeZone>
#include <entities/Vessel.h>

class HttpVesselParser : public IMessageParser<Vessel>
{
public:
    QVector<Vessel> parse(const QByteArray& message) override
    {
        QJsonParseError err;
        QJsonDocument doc = QJsonDocument::fromJson(message, &err);
        if (err.error != QJsonParseError::NoError || !doc.isArray())
            return {};

        QVector<Vessel> vessels;
        QJsonArray arr = doc.array();
        vessels.reserve(arr.size());

        for (const QJsonValue& item : arr) {
            if (!item.isObject()) continue;
            QJsonObject wrapper = item.toObject();

            if (!wrapper.contains("AIS") || !wrapper["AIS"].isObject()) continue;
            QJsonObject ais = wrapper["AIS"].toObject();

            Vessel v;

            // Unique identity
            v.mmsi          = QString::number(ais.value("MMSI").toVariant().toLongLong());
            v.uidForHistory = v.mmsi;
            v.sourceName    = ais.value("SRC").toString();

            // BaseTrack fields
            v.name  = ais.value("NAME").toString();
            v.state = QString::number(ais.value("NAVSTAT").toInt());
            v.time  = parseTimestamp(ais.value("TIMESTAMP").toString());
            v.cog   = ais.value("COURSE").toDouble();
            v.pos   = QGeoCoordinate(
                ais.value("LATITUDE").toDouble(),
                ais.value("LONGITUDE").toDouble()
                );

            // Vessel-specific fields
            v.speed = ais.value("SPEED").toDouble();

            // HEADING: 0–359 = valid, 511 = unavailable (AIS standard).
            // Fall back to 511 when the key is missing or out of range.
            int heading = ais.value("HEADING").toInt(511);
            v.heading = (heading >= 0 && heading <= 359) ? heading : 511;

            // Antenna-to-hull offsets in metres.
            // A = bow, B = stern, C = port, D = starboard.
            v.a = ais.value("A").toInt(0);
            v.b = ais.value("B").toInt(0);
            v.c = ais.value("C").toInt(0);
            v.d = ais.value("D").toInt(0);

            vessels.append(v);
        }

        return vessels;
    }

private:
    int parseTimestamp(const QString& ts)
    {
        QDateTime dt = QDateTime::fromString(ts, "yyyy-MM-dd HH:mm:ss 'UTC'");
        if (!dt.isValid())
            return 0;

        dt.setTimeZone(QTimeZone::UTC);
        return static_cast<int>(dt.toSecsSinceEpoch());
    }

};

#endif // HTTP_VESSEL_PARSER_H
