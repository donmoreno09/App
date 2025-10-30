#ifndef HISTORYPOINT_H
#define HISTORYPOINT_H

#include <QtGlobal>

class HistoryPoint {
public:
    double lat = 0.0;
    double lon = 0.0;
    double alt = 0.0;   // optional
    int time = 0;       // epoch

    bool operator<(const HistoryPoint& other) const { return time < other.time; }
    bool operator==(const HistoryPoint& other) const { return time == other.time; }
};

#endif // HISTORYPOINT_H
