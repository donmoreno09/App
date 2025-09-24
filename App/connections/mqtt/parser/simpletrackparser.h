#ifndef SIMPLETRACKPARSER_H
#define SIMPLETRACKPARSER_H

#include "imessageparser.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>


class SimpleTrackParser : public IMessageParser {
public:
    QVariantList parse(const QByteArray& message) override {
        QJsonParseError err;
        QJsonDocument doc = QJsonDocument::fromJson(message, &err);
        if (err.error != QJsonParseError::NoError || !doc.isArray()) {
            return {};
        }

        QVariantList parsedTracks;
        QJsonArray tracksArray = doc.array();
        for (const QJsonValue& trackVal : tracksArray) {
            if (trackVal.isObject()) {
                parsedTracks.append(trackVal.toObject().toVariantMap());
            }
        }

        return parsedTracks;
    }
};

#endif // SIMPLETRACKPARSER_H
