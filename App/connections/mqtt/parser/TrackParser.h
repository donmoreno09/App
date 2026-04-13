#ifndef TRACKPARSER_H
#define TRACKPARSER_H

#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QVector>
#include <QGeoCoordinate>

#include "interfaces/IMessageParser.h"
#include "entities/ClusteredPayload.h"
#include "entities/Track.h"
#include "entities/Velocity.h"
#include "HistoryParser.h"

class TrackParser : public IMessageParser<ClusteredPayload<Track>> {
public:
    ClusteredPayload<Track> parse(const QByteArray& message) override
    {
        QJsonParseError err;
        const QJsonDocument doc = QJsonDocument::fromJson(message, &err);
        if (err.error != QJsonParseError::NoError) {
            return {};
        }

        return parseClusteredPayload<Track>(doc, [this](const QJsonArray &tracksArray) {
            return parseTracks(tracksArray);
        });
    }

private:
    QVector<Track> parseTracks(const QJsonArray &rawTracks) const
    {
        QVector<Track> tracks;
        tracks.reserve(rawTracks.size());

        for (const QJsonValue& rawTrack : std::as_const(rawTracks)) {
            if (!rawTrack.isObject()) continue;

            const QJsonObject trackVal = rawTrack.toObject();

            Track track;
            track.uidForHistory = trackVal["iridess_uid"].toString();
            track.name = trackVal["name"].toString();
            track.code = trackVal["code"].toString();
            track.entity = trackVal["entity"].toString();
            track.pos = parseCoordinateArray(trackVal["pos"].toArray());
            track.cog = trackVal["cog"].toDouble();
            track.sourceName = trackVal["source_name"].toString();
            track.time = trackVal["time"].toInt();
            track.trackUid = trackVal["track_uid"].toString();
            track.trackNumber = trackVal["tracknumber"].toInt();
            track.state = trackVal["state"].toString();

            const QJsonArray velArr = trackVal["vel"].toArray();
            if (velArr.size() >= 3) {
                track.vel = Velocity(
                    velArr.at(0).toDouble(),
                    velArr.at(1).toDouble(),
                    velArr.at(2).toDouble()
                );
            }

            const QJsonValue histVal = trackVal.value("history");
            if (histVal.isArray()) {
                track.history = HistoryParser::parseArray(histVal.toArray());
            }

            tracks.append(track);
        }

        return tracks;
    }
};

#endif // TRACKPARSER_H
