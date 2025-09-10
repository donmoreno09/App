#include "clock.h"
#include <QtQml>


static void qRegister()
{
    qmlRegisterType<MonotonicTime>("qml.commons.monotonic.time", 1, 0, "MonotonicTime");
}

Q_COREAPP_STARTUP_FUNCTION(qRegister);

MonotonicTime::MonotonicTime()
{
}

qint64 MonotonicTime::monotonicMillis()
{
    auto milliseconds = std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::steady_clock::now().time_since_epoch()).count();
    return milliseconds;
}

qreal MonotonicTime::monotonicFractSecs()
{


    auto milliseconds = std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::steady_clock::now().time_since_epoch()).count();
    return milliseconds / 1000.0;
}



