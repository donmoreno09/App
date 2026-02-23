#ifndef HISTORYPARSER_H
#define HISTORYPARSER_H

#include <QJsonArray>
#include <QJsonObject>
#include <QJsonValue>
#include <QVector>
#include <algorithm>

#include "entities/HistoryPoint.h"

class HistoryParser {
public:
    static QVector<HistoryPoint> parseArray(const QJsonArray& hist)
    {
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
};

#endif // HISTORYPARSER_H
