#ifndef LOGGER_H
#define LOGGER_H

#include <QtCore/QDateTime>
#include <QtCore/QDir>
#include <QtCore/QMutex>
#include <QtCore/QPair>
#include <QtCore/QStandardPaths>
#include <QtCore/QString>
#include <QtCore/QThread>
#include <QtCore/QVariant>
#include <QtCore/QVariantMap>

#include <functional>
#include <initializer_list>
#include <memory>
#include <unordered_map>

#include "LogRecord.h"
#include "LogTypes.h"
#include "SinkRegistry.h"
#include "sinks/ILogSink.h"

class Logger {
public:
    // Factory: creates a logger with Console sink pre-registered and set as default.
    static Logger create();

    // Returns a sane default path for the SQLite file based on AppDataLocation.
    static QString defaultSqlitePath();

    // ── Default sinks ergonomics ────────────────────────────────────────────────
    Logger withDefaultSinks(std::initializer_list<Sink> sinks) const;
    Logger withDefaultSinks(Sinks sinks) const;

    // ── Context/child loggers ──────────────────────────────────────────────────
    Logger child(std::initializer_list<QPair<QString, QVariant>> ctx) const;
    Logger child(const QVariantMap& ctx) const;

    // Global minimum level filter
    Logger withMinLevel(LogLevel level) const;

    // ── Lazy factory registration ───────────────────────────────────────────────
    Logger& registerSinkFactory(Sink id, std::function<std::shared_ptr<ILogSink>()> factory);

    // ── Utilities ───────────────────────────────────────────────────────────────
    Logger& warmUp(std::initializer_list<Sink> sinks);
    bool ensureSink(Sink sink) const;

    Logger& flush();
    Logger& shutdown();

    void enableSink(Sink sink);
    void disableSink(Sink sink);
    SinkRegistry& sinkRegistry();

    void info(const QString& msg, std::initializer_list<QPair<QString, QVariant>> fields = {}) const;
    void warn(const QString& msg, std::initializer_list<QPair<QString, QVariant>> fields = {}) const;
    void error(const QString& msg, std::initializer_list<QPair<QString, QVariant>> fields = {}) const;

    void info(const QString& msg, const QVariantMap& fields) const;
    void warn(const QString& msg, const QVariantMap& fields) const;
    void error(const QString& msg, const QVariantMap& fields) const;

    // ── One-shot sink override (per-log call) ──────────────────────────────────
    class WithSinks {
    public:
        WithSinks(const Logger& base, Sinks sinks);

        void info(const QString& msg, std::initializer_list<QPair<QString, QVariant>> fields = {}) const;
        void warn(const QString& msg, std::initializer_list<QPair<QString, QVariant>> fields = {}) const;
        void error(const QString& msg, std::initializer_list<QPair<QString, QVariant>> fields = {}) const;

    private:
        const Logger& m_base;
        Sinks m_sinks;
    };

    WithSinks withSinks(std::initializer_list<Sink> sinks) const;
    WithSinks withSinks(Sinks sink) const;

    class WithContext {
    public:
        WithContext(const Logger& base, std::initializer_list<QPair<QString, QVariant>> ctx);

        void info(const QString& msg, std::initializer_list<QPair<QString, QVariant>> fields = {}) const;
        void warn(const QString& msg, std::initializer_list<QPair<QString, QVariant>> fields = {}) const;
        void error(const QString& msg, std::initializer_list<QPair<QString, QVariant>> fields = {}) const;

    private:
        std::unique_ptr<Logger> m_logger;
    };

    WithContext withContext(std::initializer_list<QPair<QString, QVariant>> ctx) const;

    WithContext withService(const QString& serviceName) const;

private:
    static Sinks maskFromList(std::initializer_list<Sink> sinks);

    void fanOut(const LogRecord& record, Sinks mask) const;

    void log(LogLevel level,
             const QString& msg,
             std::initializer_list<QPair<QString,QVariant>> fields,
             Sinks sinksOverride) const;

    void log(LogLevel level,
             const QString& msg,
             const QVariantMap& fields,
             Sinks sinksOverride) const;

private:
    // Shared registry of sinks (shared_ptr so child/copies see the same sinks).
    mutable std::shared_ptr<SinkRegistry> m_registry;
    // Mutex shared across copies for thread-safe lazy sink creation.
    mutable std::shared_ptr<QMutex> m_regMutex;
    // Structured context propagated to every log record of this logger/children.
    QVariantMap m_context;
    // Sinks mask used when no per-call override is provided.
    Sinks m_sinks = Sink::Console;
    // Global minimum level (INFO/WARN/ERROR).
    LogLevel m_minLevel = LogLevel::Info;

    // Lazy factories keyed by Sink enum; copied into children for same behavior.
    std::unordered_map<Sink, std::function<std::shared_ptr<ILogSink>()>, SinkRegistry::SinkHash> m_factories;
};

#endif // LOGGER_H
