#ifndef TRACKPARSER_H
#define TRACKPARSER_H

#include "IMessageParser.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QVector>
#include <QGeoCoordinate>
#include <entities/Track.h>
#include <entities/Velocity.h>


class TrackParser : public IMessageParser<Track> {
public:
    QVector<Track> parse(const QByteArray& message) override {
        QJsonParseError err;
        QJsonDocument doc = QJsonDocument::fromJson(message, &err);
        if (err.error != QJsonParseError::NoError || !doc.isArray()) {
            return {};
        }

        QVector<Track> tracks;
        QJsonArray rawTracks = doc.array();
        for (const QJsonValue& rawTrack : std::as_const(rawTracks)) {
            if (!rawTrack.isObject()) continue;

            auto trackVal = rawTrack.toObject();

            Track track;
            track.name = trackVal["name"].toString();
            track.code = trackVal["code"].toString();
            track.entity = trackVal["entity"].toString();
            track.pos = parseCoordinateArray(trackVal["pos"].toArray());
            track.cog = trackVal["cog"].toDouble();
            track.sourceName = trackVal["source_name"].toString();
            track.time = trackVal["time"].toInt();
            track.trackUid = trackVal["track_uid"].toString();
            track.trackNumber = trackVal["tracknumber"].toInt();
            track.vel = Velocity(
                trackVal["vel"].toArray().at(0).toDouble(),
                trackVal["vel"].toArray().at(1).toDouble(),
                trackVal["vel"].toArray().at(2).toDouble()
            );
            track.state = trackVal["state"].toString();
            tracks.append(track);
        }

        return tracks;
    }
};

#endif // TRACKPARSER_H
