#ifndef CLOCK_H
#define CLOCK_H

#include <QObject>
#include "registertemplate.h"

class MonotonicTime: public QObject
{
    Q_OBJECT
    static Register::QmlCreatableType<MonotonicTime> Register;


public:
    MonotonicTime();

public slots:
    qint64 monotonicMillis();
    qreal monotonicFractSecs();


};

#endif // CLOCK_H
