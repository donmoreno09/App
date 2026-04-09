#ifndef TRAILERPREDICTIONSLOGGER_H
#define TRAILERPREDICTIONSLOGGER_H

#include <QtQml/qqmlregistration.h>
#include <QtQml/qqmlengine.h>
#include <QJSEngine>

#include "AppLogger.h"

class TrailerPredictionsLogger final : public BaseLogger {
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    static TrailerPredictionsLogger* create(QQmlEngine* qmlEngine, QJSEngine* jsEngine) {
        Q_UNUSED(qmlEngine)
        Q_UNUSED(jsEngine)

        static TrailerPredictionsLogger instance;
        QJSEngine::setObjectOwnership(&instance, QJSEngine::CppOwnership);
        (void)get();
        return &instance;
    }

    static Logger& get() {
        static Logger logger = AppLogger::get().child({
            {"module", "App.Features.TrailerPredictions"},
            {"service", "TRAILER_PREDICTIONS"},
        });
        return logger;
    }

protected:
    Logger& logger() override { return get(); }

private:
    explicit TrailerPredictionsLogger(QObject* parent = nullptr) : BaseLogger(parent) {}
    Q_DISABLE_COPY_MOVE(TrailerPredictionsLogger)
};

#endif // TRAILERPREDICTIONSLOGGER_H
