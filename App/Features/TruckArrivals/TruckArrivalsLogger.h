#ifndef TRUCKARRIVALSLOGGER_H
#define TRUCKARRIVALSLOGGER_H

#include <QtQml/qqmlregistration.h>
#include <QtQml/qqmlengine.h>
#include <QJSEngine>

#include "AppLogger.h"

class TruckArrivalsLogger final : public BaseLogger {
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    static TruckArrivalsLogger* create(QQmlEngine* qmlEngine, QJSEngine* jsEngine) {
        Q_UNUSED(qmlEngine)
        Q_UNUSED(jsEngine)

        static TruckArrivalsLogger instance;
        QJSEngine::setObjectOwnership(&instance, QJSEngine::CppOwnership);
        (void)get();
        return &instance;
    }

    static Logger& get() {
        static Logger logger = AppLogger::get().child({
                                                       {"module", "App.Features.TruckArrivals"},
                                                       {"service", "TRUCK_ARRIVALS"},
                                                       });
        return logger;
    }

protected:
    Logger& logger() override { return get(); }

private:
    explicit TruckArrivalsLogger(QObject* parent = nullptr) : BaseLogger(parent) {}
    Q_DISABLE_COPY_MOVE(TruckArrivalsLogger)
};

#endif // TRUCKARRIVALSLOGGER_H
