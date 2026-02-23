#ifndef TIRPARSER_H
#define TIRPARSER_H

#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QVector>
#include <QGeoCoordinate>

#include "interfaces/IMessageParser.h"
#include "entities/Tir.h"
#include "HistoryParser.h"

class TirParser : public IMessageParser<Tir> {
public:
    QVector<Tir> parse(const QByteArray& message) override
    {
        QJsonParseError err;
        const QJsonDocument doc = QJsonDocument::fromJson(message, &err);
        if (err.error != QJsonParseError::NoError || !doc.isArray()) {
            return {};
        }

        QVector<Tir> tirs;
        const QJsonArray rawTirs = doc.array();

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
