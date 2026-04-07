#ifndef POI_LOGGER_H
#define POI_LOGGER_H

#include <QtQml/qqmlregistration.h>
#include <QtQml/qqmlengine.h>
#include <QJSEngine>

#include "AppLogger.h"
#include "core/BaseLogger.h"

class PoiLogger final : public BaseLogger {
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    // QML will call this to obtain the singleton instance (instead of constructing)
    static PoiLogger* create(QQmlEngine* qmlEngine, QJSEngine* jsEngine) {
        Q_UNUSED(qmlEngine)
        Q_UNUSED(jsEngine)

        static PoiLogger instance;
        QJSEngine::setObjectOwnership(&instance, QJSEngine::CppOwnership);
        (void)get();
        return &instance;
    }

    static Logger& get() {
        static Logger logger = AppLogger::get().child({
            {"service", "PoIs"}
        });
        return logger;
    }

protected:
    Logger& logger() override { return get(); }

private:
    // Make AppLogger non-constructible from QML so it can't create a second instance
    explicit PoiLogger(QObject* parent = nullptr) : BaseLogger(parent) {}
    Q_DISABLE_COPY_MOVE(PoiLogger)
};
#endif // POI_LOGGER_H
