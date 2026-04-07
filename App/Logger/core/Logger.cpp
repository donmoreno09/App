#include "Logger.h"

#include <QtCore/QDebug>
#include <QtCore/QMutexLocker>

#include "sinks/ConsoleSink.h"

Logger Logger::create() {
    Logger logger;
    logger.m_sinks = Sink::Console;
    logger.m_registry = std::make_shared<SinkRegistry>(); // shared registry across copies/children
    logger.m_regMutex = std::make_shared<QMutex>(); // protects lazy sink creation
    logger.m_registry->emplace<ConsoleSink>(Sink::Console);
    return logger;
}

QString Logger::defaultSqlitePath() {
    const auto dir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(dir);
    qDebug() << "[Logger] sqlite db path:" << (dir + "/logs.sqlite");
    return dir + "/logs.sqlite";
}

Logger Logger::withDefaultSinks(std::initializer_list<Sink> sinks) const {
    return withDefaultSinks(maskFromList(sinks));
}

Logger Logger::withDefaultSinks(Sinks sinks) const {
    Logger newLogger(*this);
    newLogger.m_sinks = sinks;
    return newLogger;
}

Logger Logger::child(std::initializer_list<QPair<QString, QVariant>> ctx) const {
    QVariantMap map;
    for (const auto& prop : ctx) map.insert(prop.first, prop.second);
    return child(map);
}

Logger Logger::child(const QVariantMap& ctx) const {
    Logger newLogger(*this);
    newLogger.m_context.insert(ctx);
    return newLogger;
}

Logger Logger::withMinLevel(LogLevel level) const {
    Logger newLogger(*this);
    newLogger.m_minLevel = level;
    return newLogger;
}

Logger& Logger::registerSinkFactory(Sink id, std::function<std::shared_ptr<ILogSink>()> factory) {
    m_factories[id] = std::move(factory);
    return *this;
}

Logger& Logger::warmUp(std::initializer_list<Sink> sinks) {
    for (auto sink : sinks) ensureSink(sink);
    return *this;
}

bool Logger::ensureSink(Sink sink) const {
    if (!m_registry || !m_regMutex) {
        qWarning() << "[Logger] Cannot create sink: registry/mutex not initialized";
        return false;
    }

    if (m_registry->get(sink)) return true;

    QMutexLocker lock(m_regMutex.get());
    if (m_registry->get(sink)) return true;

    auto it = m_factories.find(sink);
    if (it == m_factories.end()) {
        qWarning() << "[Logger] Cannot create sink: no factory registered for id=" << int(sink);
        return false;
    }

    auto ptr = it->second();
    if (!ptr) {
        qWarning() << "[Logger] Cannot create sink: factory returned nullptr for id=" << int(sink);
        return false;
    }

    m_registry->set(sink, std::move(ptr));
    return true;
}

Logger& Logger::flush() {
    if (m_registry) {
        m_registry->forEach([](ILogSink* sink){ if (sink) sink->flush(); });
    }

    return *this;
}

Logger& Logger::shutdown() {
    if (m_registry) {
        m_registry->forEach([](ILogSink* sink){ if (sink) sink->shutdown(); });
    }

    return *this;
}

void Logger::enableSink(Sink sink)
{
    m_sinks |= sink;
}

void Logger::disableSink(Sink sink)
{
    m_sinks &= ~Sinks{sink};
}

SinkRegistry& Logger::sinkRegistry() {
    return *m_registry;
}

void Logger::info(const QString& msg, std::initializer_list<QPair<QString,QVariant>> fields) const {
    log(LogLevel::Info, msg, fields, Sinks());
}

void Logger::warn(const QString& msg, std::initializer_list<QPair<QString,QVariant>> fields) const {
    log(LogLevel::Warn, msg, fields, Sinks());
}

void Logger::error(const QString& msg, std::initializer_list<QPair<QString,QVariant>> fields) const {
    log(LogLevel::Error, msg, fields, Sinks());
}

void Logger::info(const QString& msg, const QVariantMap& fields) const {
    log(LogLevel::Info, msg, fields, Sinks());
}

void Logger::warn(const QString& msg, const QVariantMap& fields) const {
    log(LogLevel::Warn, msg, fields, Sinks());
}

void Logger::error(const QString& msg, const QVariantMap& fields) const {
    log(LogLevel::Error, msg, fields, Sinks());
}

Sinks Logger::maskFromList(std::initializer_list<Sink> sinks) {
    Sinks masked;
    for (auto sink : sinks) masked |= sink;
    return masked;
}

void Logger::fanOut(const LogRecord& record, Sinks mask) const {
    // Deterministic sink call order lives here.
    static constexpr Sink kOrder[] = { Sink::Console, Sink::SQLiteDB };

    for (Sink id : kOrder) {
        if (!mask.testFlag(id)) continue;
        if (!ensureSink(id))    continue;

        if (auto* sink = m_registry->get(id)) {
            sink->write(record);
        }
    }
}

void Logger::log(LogLevel level,
                 const QString& msg,
                 std::initializer_list<QPair<QString,QVariant>> fields,
                 Sinks sinksOverride) const
{
    QVariantMap map;
    for (const auto& field : fields) map.insert(field.first, field.second);
    log(level, msg, map, sinksOverride);
}

void Logger::log(LogLevel level,
                 const QString& msg,
                 const QVariantMap& fields,
                 Sinks sinksOverride) const
{
    if (static_cast<int>(level) < static_cast<int>(m_minLevel)) return;

    LogRecord record;
    record.level = level;
    record.msg = msg;
    record.context = m_context;
    record.tsMs = QDateTime::currentMSecsSinceEpoch();
    record.threadId = QThread::currentThreadId();
    record.fields = fields; // copy

    const Sinks resolved = (sinksOverride == Sinks()) ? m_sinks : sinksOverride;
    fanOut(record, resolved);
}

// ── One-shot sink override (per-log call) ──────────────────────────────────

Logger::WithSinks::WithSinks(const Logger& base, Sinks sinks)
    : m_base(base)
    , m_sinks(sinks)
{}

void Logger::WithSinks::info(const QString& msg, std::initializer_list<QPair<QString, QVariant>> fields) const {
    m_base.log(LogLevel::Info, msg, fields, m_sinks);
}

void Logger::WithSinks::warn(const QString& msg, std::initializer_list<QPair<QString, QVariant>> fields) const {
    m_base.log(LogLevel::Warn, msg, fields, m_sinks);
}

void Logger::WithSinks::error(const QString& msg, std::initializer_list<QPair<QString, QVariant>> fields) const {
    m_base.log(LogLevel::Error, msg, fields, m_sinks);
}

Logger::WithSinks Logger::withSinks(std::initializer_list<Sink> sinks) const {
    return WithSinks(*this, maskFromList(sinks));
}

Logger::WithSinks Logger::withSinks(Sinks sinks) const {
    return WithSinks(*this, sinks);
}

Logger::WithContext::WithContext(const Logger& base, std::initializer_list<QPair<QString, QVariant>> ctx)
    : m_logger(std::make_unique<Logger>(base.child(ctx)))
{}

void Logger::WithContext::info(const QString& msg, std::initializer_list<QPair<QString, QVariant>> fields) const {
    m_logger->log(LogLevel::Info, msg, fields, Sinks());
}

void Logger::WithContext::warn(const QString& msg, std::initializer_list<QPair<QString, QVariant>> fields) const {
    m_logger->log(LogLevel::Warn, msg, fields, Sinks());
}

void Logger::WithContext::error(const QString& msg, std::initializer_list<QPair<QString, QVariant>> fields) const {
    m_logger->log(LogLevel::Error, msg, fields, Sinks());
}

Logger::WithContext Logger::withContext(std::initializer_list<QPair<QString, QVariant>> ctx) const {
    return WithContext(*this, ctx);
}

Logger::WithContext Logger::withService(const QString &serviceName) const {
    return WithContext(*this, {kv("service", serviceName)});
}
