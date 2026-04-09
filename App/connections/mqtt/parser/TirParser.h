#ifndef TIRPARSER_H
#define TIRPARSER_H

#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QVector>
#include <QGeoCoordinate>

#include "interfaces/IMessageParser.h"
#include "entities/ClusteredPayload.h"
#include "entities/Tir.h"
#include "HistoryParser.h"

class TirParser : public IMessageParser<ClusteredPayload<Tir>> {
public:
    ClusteredPayload<Tir> parse(const QByteArray& message) override
    {
        QJsonParseError err;
        const QJsonDocument doc = QJsonDocument::fromJson(message, &err);
        if (err.error != QJsonParseError::NoError) {
            return {};
        }

        return parseClusteredPayload<Tir>(doc, [this](const QJsonArray &tracksArray) {
            return parseTracks(tracksArray);
        });
    }

private:
    QVector<Tir> parseTracks(const QJsonArray &rawTirs) const
    {
        QVector<Tir> tirs;
        tirs.reserve(rawTirs.size());

        for (const QJsonValue& rawTir : std::as_const(rawTirs)) {
            if (!rawTir.isObject()) continue;

            const QJsonObject tirVal = rawTir.toObject();

            Tir tir;
            tir.operationCode = tirVal["operationCode"].toString();
            tir.uidForHistory = tirVal["iridess_uid"].toString(tir.operationCode);
            tir.name = tirVal["name"].toString(tir.operationCode);
            tir.pos = parseCoordinateArray(tirVal["pos"].toArray(), false);
            tir.cog = tirVal["cog"].toDouble();
            tir.sourceName = tirVal["source_name"].toString("tir");
            tir.time = tirVal["time"].toInt();
            tir.vel = tirVal["vel"].toDouble();
            tir.state = tirVal["state"].toString();

            const QJsonValue histVal = tirVal["history"];
            if (histVal.isArray()) {
                tir.history = HistoryParser::parseArray(histVal.toArray());
            }

            tirs.append(tir);
        }

        return tirs;
    }
};

#endif // TIRPARSER_H
