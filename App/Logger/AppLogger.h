#ifndef APP_LOGGER_H
#define APP_LOGGER_H

#include <QtQml/qqmlregistration.h>
#include <QtQml/qqmlengine.h>
#include <QJSEngine>

#include "core/BaseLogger.h"
#include "core/LoggerQmlHandle.h"
#include "sinks/SqliteSink.h"

class AppLogger final : public BaseLogger {
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    // QML will call this to obtain the singleton instance (instead of constructing)
    // that's why we make the AppLogger non-constructible
    static AppLogger* create(QQmlEngine* qmlEngine, QJSEngine* jsEngine) {
        Q_UNUSED(qmlEngine)
        Q_UNUSED(jsEngine)

        static AppLogger instance;
        QJSEngine::setObjectOwnership(&instance, QJSEngine::CppOwnership);
        (void)get(); // ensure Logger is initialized once
        return &instance;
    }

    static Logger& get() {
        static Logger logger = createAndInit();
        return logger;
    }

    // It's okay for AppLogger to handle logger's context because
    // it's a global logger, not really a specialized one.
    Q_INVOKABLE LoggerQmlHandle* withContext(const QVariantMap& ctx) {
        auto* handle = new LoggerQmlHandle(logger().child(ctx));
        QJSEngine::setObjectOwnership(handle, QJSEngine::JavaScriptOwnership);
        return handle;
    }

    Q_INVOKABLE LoggerQmlHandle* withService(const QString& serviceName) {
        return withContext({{"service", serviceName}});
    }

protected:
    Logger& logger() override { return get(); }

private:
    // Make AppLogger non-constructible from QML so it can't create a second instance
    explicit AppLogger(QObject* parent = nullptr) : BaseLogger(parent) {}
    Q_DISABLE_COPY_MOVE(AppLogger)

    static Logger createAndInit() {
        Logger logger = Logger::create();
        logger = logger.withDefaultSinks({ Sink::Console, Sink::SQLiteDB });

        logger.registerSinkFactory(Sink::SQLiteDB, [] {
            return std::make_shared<SqliteSink>(
                Logger::defaultSqlitePath(),
                /*batch=*/64,
                /*WAL=*/true,
                /*sync=*/true
                );
        });

        // Avoid first-log cold start for SQLite.
        logger.warmUp({ Sink::SQLiteDB });

        // Best-effort shutdown hook (safe even if never triggered).
        if (auto* app = QCoreApplication::instance()) {
            QObject::connect(app, &QCoreApplication::aboutToQuit, app, [] {
                auto& logger = AppLogger::get();
                logger.flush();
                logger.shutdown();
            });
        }

        return logger;
    }
};

#endif // APP_LOGGER_H
