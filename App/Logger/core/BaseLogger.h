#ifndef BASELOGGER_H
#define BASELOGGER_H

#include <QObject>
#include <QVariantMap>
#include <QJSEngine>

#include "Logger.h"

class BaseLogger : public QObject {
    Q_OBJECT

public:
    explicit BaseLogger(QObject* parent = nullptr) : QObject(parent) {}

    Q_INVOKABLE void info(const QString& message, const QVariantMap& fields = {}) { logger().info (message, fields); }
    Q_INVOKABLE void warn(const QString& message, const QVariantMap& fields = {}) { logger().warn (message, fields); }
    Q_INVOKABLE void error(const QString& message, const QVariantMap& fields = {}) { logger().error(message, fields); }

    Q_INVOKABLE void flush() { logger().flush(); }

protected:
    virtual Logger& logger() = 0;
};

#endif // BASELOGGER_H
