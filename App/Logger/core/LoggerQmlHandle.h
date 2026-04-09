#ifndef LOGGERQMLHANDLE_H
#define LOGGERQMLHANDLE_H

#include <QObject>
#include <QVariantMap>
#include <QtQml/qqmlengine.h>

#include "BaseLogger.h"

// Lightweight, temporary "logger handle" used for fluent QML calls.
// Example: AppLogger.withContext({...}) returns an instance of this class,
// which wraps a context-customized Logger and forwards info/warn/error calls.
class LoggerQmlHandle final : public BaseLogger {
    Q_OBJECT
    Q_DISABLE_COPY_MOVE(LoggerQmlHandle)

public:
    explicit LoggerQmlHandle(Logger logger, QObject* parent = nullptr)
        : BaseLogger(parent), m_logger(std::move(logger)) {}

protected:
    Logger& logger() override { return m_logger; }

private:
    Logger m_logger;
};

#endif // LOGGERQMLHANDLE_H
