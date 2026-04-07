#ifndef NETWORKINGLOGGER_H
#define NETWORKINGLOGGER_H

#include <QtQml/qqmlregistration.h>
#include <QtQml/qqmlengine.h>
#include <QJSEngine>

#include "AppLogger.h"

class NetworkingLogger final : public BaseLogger {
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    // QML will call this to obtain the singleton instance (instead of constructing)
    static NetworkingLogger* create(QQmlEngine* qmlEngine, QJSEngine* jsEngine) {
        Q_UNUSED(qmlEngine)
        Q_UNUSED(jsEngine)

        static NetworkingLogger instance;
        QJSEngine::setObjectOwnership(&instance, QJSEngine::CppOwnership);
        (void)get();
        return &instance;
    }

    static Logger& get() {
        static Logger logger = AppLogger::get().child({
            {"module", "App.Networking"},
            {"service", "NETWORKING"},
        });
        return logger;
    }

protected:
    Logger& logger() override { return get(); }

private:
    // Make AppLogger non-constructible from QML so it can't create a second instance
    explicit NetworkingLogger(QObject* parent = nullptr) : BaseLogger(parent) {}
    Q_DISABLE_COPY_MOVE(NetworkingLogger)
};

#endif // NETWORKINGLOGGER_H
