#ifndef VESSEL_H
#define VESSEL_H

#include <QString>
#include "BaseTrack.h"

class Vessel : public BaseTrack
{
public:
    QString mmsi;        // MMSI        (unique identifier)
    QString sourceName;  // SRC         (data source name)
    int     heading;     // HEADING     (0–359 degrees, 511 = unavailable)
    double  speed;       // SPEED       (knots)
    int     a;           // A           (bow → antenna, metres)
    int     b;           // B           (stern → antenna, metres)
    int     c;           // C           (port → antenna, metres)
    int     d;           // D           (starboard → antenna, metres)

    int    shipLength()     const { return a + b; }
    int    shipWidth()      const { return c + d; }
    bool   hasDimensions()  const { return shipLength() > 0 && shipWidth() > 0; }
    double displayHeading() const { return heading == 511 ? cog : static_cast<double>(heading); }
};

#endif // VESSEL_H
