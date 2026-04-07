#ifndef HTTP_VESSEL_PARSER_H
#define HTTP_VESSEL_PARSER_H

#include "interfaces/IMessageParser.h"

#include <QDateTime>
#include <QGeoCoordinate>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QTimeZone>

#include <entities/ClusteredPayload.h>
#include <entities/Vessel.h>

class HttpVesselParser : public IMessageParser<ClusteredPayload<Vessel>>
{
public:
    ClusteredPayload<Vessel> parse(const QByteArray& message) override
    {
        QJsonParseError err;
        const QJsonDocument doc = QJsonDocument::fromJson(message, &err);
        if (err.error != QJsonParseError::NoError)
            return {};

        return parseClusteredPayload<Vessel>(doc, [this](const QJsonArray &tracksArray) {
            return parseTracks(tracksArray);
        });
    }

private:
    QVector<Vessel> parseTracks(const QJsonArray &tracksArray) const
    {
        QVector<Vessel> tracks;
        tracks.reserve(tracksArray.size());

        for (const QJsonValue &value : tracksArray) {
            if (!value.isObject())
                continue;

            const QJsonObject wrapper = value.toObject();
            const QJsonValue aisValue = wrapper.value("AIS");
            if (!aisValue.isObject())
                continue;

            const QJsonObject ais = aisValue.toObject();

            Vessel vessel;

            // Unique identity
            vessel.mmsi = QString::number(ais.value("MMSI").toVariant().toLongLong());
            vessel.uidForHistory = vessel.mmsi;
            vessel.sourceName = ais.value("SRC").toString();

            // BaseTrack fields
            vessel.name = ais.value("NAME").toString();
            vessel.state = QString::number(ais.value("NAVSTAT").toInt());
            vessel.time = parseTimestamp(ais.value("TIMESTAMP").toString());
            vessel.cog = ais.value("COURSE").toDouble();
            vessel.pos = QGeoCoordinate(
                ais.value("LATITUDE").toDouble(),
                ais.value("LONGITUDE").toDouble()
            );

            // Vessel-specific fields
            vessel.speed = ais.value("SPEED").toDouble();

            // HEADING: 0–359 = valid, 511 = unavailable (AIS standard).
            // Fall back to 511 when the key is missing or out of range.
            const int heading = ais.value("HEADING").toInt(511);
            vessel.heading = (heading >= 0 && heading <= 359) ? heading : 511;

            // Antenna-to-hull offsets in metres.
            // A = bow, B = stern, C = port, D = starboard.
            vessel.a = ais.value("A").toInt(0);
            vessel.b = ais.value("B").toInt(0);
            vessel.c = ais.value("C").toInt(0);
            vessel.d = ais.value("D").toInt(0);

            tracks.append(vessel);
        }

        return tracks;
    }

    int parseTimestamp(const QString& ts) const
    {
        QDateTime dt = QDateTime::fromString(ts, "yyyy-MM-dd HH:mm:ss 'UTC'");
        if (!dt.isValid())
            return 0;

        dt.setTimeZone(QTimeZone::UTC);
        return static_cast<int>(dt.toSecsSinceEpoch());
    }
};

#endif // HTTP_VESSEL_PARSER_H
