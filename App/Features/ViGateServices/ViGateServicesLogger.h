#ifndef VIGATESERVICESLOGGER_H
#define VIGATESERVICESLOGGER_H

#include <QtQml/qqmlregistration.h>
#include <QtQml/qqmlengine.h>
#include <QJSEngine>

#include "AppLogger.h"

class ViGateServicesLogger final : public BaseLogger {
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    static ViGateServicesLogger* create(QQmlEngine* qmlEngine, QJSEngine* jsEngine) {
        Q_UNUSED(qmlEngine)
        Q_UNUSED(jsEngine)

        static ViGateServicesLogger instance;
        QJSEngine::setObjectOwnership(&instance, QJSEngine::CppOwnership);
        (void)get();
        return &instance;
    }

    static Logger& get() {
        static Logger logger = AppLogger::get().child({
            {"module", "App.Features.ViGateServices"},
            {"service", "VIGATE_SERVICES"},
        });
        return logger;
    }

protected:
    Logger& logger() override { return get(); }

private:
    explicit ViGateServicesLogger(QObject* parent = nullptr) : BaseLogger(parent) {}
    Q_DISABLE_COPY_MOVE(ViGateServicesLogger)
};

#endif // VIGATESERVICESLOGGER_H
