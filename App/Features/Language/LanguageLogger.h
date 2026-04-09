#ifndef LANGUAGELOGGER_H
#define LANGUAGELOGGER_H

#include <QtQml/qqmlregistration.h>
#include <QtQml/qqmlengine.h>
#include <QJSEngine>

#include "AppLogger.h"

class LanguageLogger final : public BaseLogger {
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    // QML will call this to obtain the singleton instance (instead of constructing)
    static LanguageLogger* create(QQmlEngine* qmlEngine, QJSEngine* jsEngine) {
        Q_UNUSED(qmlEngine)
        Q_UNUSED(jsEngine)

        static LanguageLogger instance;
        QJSEngine::setObjectOwnership(&instance, QJSEngine::CppOwnership);
        (void)get();
        return &instance;
    }

    static Logger& get() {
        static Logger logger = AppLogger::get().child({
            {"module", "App.Features.Language"},
            {"service", "LANGUAGE"},
        });
        return logger;
    }

protected:
    Logger& logger() override { return get(); }

private:
    // Make AppLogger non-constructible from QML so it can't create a second instance
    explicit LanguageLogger(QObject* parent = nullptr) : BaseLogger(parent) {}
    Q_DISABLE_COPY_MOVE(LanguageLogger)
};

#endif // LANGUAGELOGGER_H
