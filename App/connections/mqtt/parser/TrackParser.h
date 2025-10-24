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
    static QVector<HistoryPoint> parseHistoryArray(const QJsonArray& hist) {
        QVector<HistoryPoint> out;
        // Pre-allocate capacity for 'out' to avoid repeated reallocations during push_back;
        // it does NOT change size, only ensures enough space for up to hist.size() elements
        out.reserve(hist.size());
        for (const QJsonValue& v : hist) {
            if (!v.isObject()) continue;
            const QJsonObject o = v.toObject();

            HistoryPoint hp;
            const auto posArr = o.value("Pos").toArray();
            if (!posArr.isEmpty()) {
                hp.lat = posArr.size() > 0 ? posArr.at(0).toDouble() : 0.0;
                hp.lon = posArr.size() > 1 ? posArr.at(1).toDouble() : 0.0;
                hp.alt = posArr.size() > 2 ? posArr.at(2).toDouble() : 0.0;
            }
            hp.time = o.value("Time").toInt();
            out.push_back(hp);
        }
        // Sort the history points in ascending order (by operator<, here by time) so duplicates become adjacent.
        std::sort(out.begin(), out.end());
        // Remove consecutive duplicate entries (after sort) and shrink the vector to keep only unique points.
        out.erase(std::unique(out.begin(), out.end()), out.end());
        return out;
    }

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
            track.vel = Velocity(
                trackVal["vel"].toArray().at(0).toDouble(),
                trackVal["vel"].toArray().at(1).toDouble(),
                trackVal["vel"].toArray().at(2).toDouble()
            );
            track.state = trackVal["state"].toString();

            if (trackVal.contains("history") && trackVal["history"].isArray()) {
                track.history = parseHistoryArray(trackVal["history"].toArray());
            }

            tracks.append(track);
        }

        return tracks;
    }
};

#endif // TRACKPARSER_H
