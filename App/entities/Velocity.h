#ifndef VELOCITY_H
#define VELOCITY_H

#include <QtGlobal>
#include <QMetaType>
#include <QtQml>
#include <cmath>

class Velocity {
    Q_GADGET
    Q_PROPERTY(double vx MEMBER vx CONSTANT)
    Q_PROPERTY(double vy MEMBER vy CONSTANT)
    Q_PROPERTY(double vz MEMBER vz CONSTANT)
    Q_PROPERTY(double speedMs READ speedMs CONSTANT)
    Q_PROPERTY(double speedKmH READ speedKmH CONSTANT)
    Q_PROPERTY(double speedKnots READ speedKnots CONSTANT)

public:
    double vx = 0.0;
    double vy = 0.0;
    double vz = 0.0;

    Velocity() = default;
    Velocity(double x, double y, double z) : vx(x), vy(y), vz(z) {}

    double speedMs() const { return std::sqrt(vx * vx + vy * vy + vz * vz); }
    double speedKmH() const { return speedMs() * 3.6; }
    double speedKnots() const { return speedMs() * 1.94384; }

    bool isValid() const { return !std::isnan(vx) && !std::isnan(vy) && !std::isnan(vz); }
};

Q_DECLARE_METATYPE(Velocity)

#endif // VELOCITY_H
