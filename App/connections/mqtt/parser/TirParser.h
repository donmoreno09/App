#ifndef TIRPARSER_H
#define TIRPARSER_H

#include "IMessageParser.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QVector>
#include <QGeoCoordinate>
#include <entities/Tir.h>

class TirParser : public IMessageParser<Tir> {
public:
    QVector<Tir> parse(const QByteArray& message) override {
        QJsonParseError err;
        QJsonDocument doc = QJsonDocument::fromJson(message, &err);
        if (err.error != QJsonParseError::NoError || !doc.isArray()) {
            return {};
        }

        QVector<Tir> tirs;
        QJsonArray rawTirs = doc.array();
        for (const QJsonValue& rawTir : std::as_const(rawTirs)) {
            if (!rawTir.isObject()) continue;

            auto tirVal = rawTir.toObject();

            Tir tir;
            tir.uidForHistory = tirVal["operationCode"].toString();
            tir.name = tirVal["operationCode"].toString();
            tir.operationCode = tirVal["operationCode"].toString();
            tir.pos = parseCoordinateArray(tirVal["pos"].toArray(), true);
            tir.sourceName = "Tir";
            tir.cog = tirVal["cog"].toDouble();
            tir.time = tirVal["time"].toInt();
            tir.vel = tirVal["vel"].toDouble();
            tir.state = tirVal["state"].toString();

            tirs.append(tir);
        }

        return tirs;
    }
};

#endif // TIRPARSER_H
