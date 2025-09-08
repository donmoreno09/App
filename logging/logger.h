#ifndef LOGGER_H
#define LOGGER_H

#include <QtCore>
#include <QStandardPaths>
#include <QDir>
#include <QMutex>
#include <functional>
#include <unordered_map>
#include <type_traits>

#include "log_types.h"
#include "log_record.h"
#include "ilogsink.h"
#include "sink_registry.h"
#include "console_sink.h"


class Logger {
public:
    // Factory: creates a logger with Console sink pre-registered and set as default.
    static Logger create() {
        Logger l;
        l.defaultSinks_ = Sink::Console;
        l.registry_ = std::make_shared<SinkRegistry>(); // shared registry across copies/children
        l.regMutex_ = std::make_shared<QMutex>();       // protects lazy sink creation
        l.registry_->emplace<ConsoleSink>(Sink::Console);
        return l;
    }

    // Returns a sane default path for the SQLite file based on AppDataLocation.
    // NOTE: prints the path once for convenience (can be removed if too chatty).
    static QString defaultSqlitePath(){
        const auto dir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
        QDir().mkpath(dir);
        qDebug() << "[Logger] sqlite db path: " << dir + "/logs.sqlite";
        return dir + "/logs.sqlite";
    }

    // ── Default sinks ergonomics ────────────────────────────────────────────────
    // Friendly overload: pass a list of sinks, e.g. withDefaultSinks({ Console, SQLiteDB }).
    Logger withDefaultSinks(std::initializer_list<Sink> sinks) const { return withDefaultSinks(maskFromList(sinks)); }
    // Bitmask-based version (kept for flexibility and backward compatibility).
    Logger withDefaultSinks(Sinks s) const { Logger c(*this); c.defaultSinks_ = s; return c; }

    // ── Context/child loggers ──────────────────────────────────────────────────
    // Creates a child logger that inherits this logger's state and adds context key/values.
    Logger child(std::initializer_list<QPair<QString,QVariant>> ctx) const {
        Logger c(*this);
        for (auto& p : ctx) c.context_.insert(p.first, p.second);
        return c;
    }

    // ── One-shot sink override (per-log call) ──────────────────────────────────
    class WithSinks {
    public:
        // Holds a reference to the base logger and a sink mask to use for this call only.
        WithSinks(const Logger& base, Sinks s) : base_(base), sinks_(s) {}

        void info (const QString& msg, std::initializer_list<QPair<QString,QVariant>> f = {}) const { base_.log(LogLevel::Info , msg, f, sinks_); }
        void warn (const QString& msg, std::initializer_list<QPair<QString,QVariant>> f = {}) const { base_.log(LogLevel::Warn , msg, f, sinks_); }
        void error(const QString& msg, std::initializer_list<QPair<QString,QVariant>> f = {}) const { base_.log(LogLevel::Error, msg, f, sinks_); }

    private:
        const Logger& base_;
        Sinks sinks_;
    };

    // Helper to create a WithSinks using a list, e.g. withSinks({ Console, SQLiteDB }).
    WithSinks withSinks(std::initializer_list<Sink> sinks) const { return WithSinks(*this, maskFromList(sinks)); }
    // Bitmask-based WithSinks (kept for flexibility).
    WithSinks withSinks(Sinks s) const { return WithSinks(*this, s); }

    // Global minimum level filter (applies to all sinks unless you wrap per-sink elsewhere).
    Logger withMinLevel(LogLevel l) const { Logger c(*this); c.minLevel_ = l; return c; }

    // ── Lazy factory registration ───────────────────────────────────────────────
    // Registers a factory to create a sink on first use (lazy init).
    Logger& registerSinkFactory(Sink id, std::function<std::shared_ptr<ILogSink>()> factory) {
        factories_[id] = std::move(factory);
        return *this;
    }

    // ── Utilities ───────────────────────────────────────────────────────────────
    // Pre-create a set of sinks to avoid cold-start latency/first-log drop.
    Logger& warmUp(std::initializer_list<Sink> sinks){ for (auto s: sinks) ensureSink(s); return *this; }
    // Explicitly ensure a single sink exists (returns false if no factory registered).
    bool requireSink(Sink s){ return ensureSink(s); }
    // Flush all registered sinks (useful on shutdown for batched sinks).
    Logger& flush(){ registry_->forEach([](ILogSink* s){ if(s) s->flush(); }); return *this; }

    // Access the registry if you want to emplace a ready sink instead of a factory.
    SinkRegistry& sinks() { return *registry_; }

    void info (const QString& msg, std::initializer_list<QPair<QString,QVariant>> f = {}) const { log(LogLevel::Info , msg, f, Sinks()); }
    void warn (const QString& msg, std::initializer_list<QPair<QString,QVariant>> f = {}) const { log(LogLevel::Warn , msg, f, Sinks()); }
    void error(const QString& msg, std::initializer_list<QPair<QString,QVariant>> f = {}) const { log(LogLevel::Error, msg, f, Sinks()); }

private:
    // Shared registry of sinks (shared_ptr so child/copies see the same sinks).
    mutable std::shared_ptr<SinkRegistry> registry_;
    // Mutex shared across copies for thread-safe lazy sink creation.
    mutable std::shared_ptr<QMutex>       regMutex_;
    // Structured context propagated to every log record of this logger/children.
    Fields   context_;
    // Default sinks mask used when no per-call override is provided.
    Sinks    defaultSinks_ = Sink::Console;
    // Global minimum level (INFO/WARN/ERROR).
    LogLevel minLevel_     = LogLevel::Info;

    // Lazy factories keyed by Sink enum; copied into children for same behavior.
    std::unordered_map<Sink, std::function<std::shared_ptr<ILogSink>()>> factories_;

    // Packs an initializer_list<Sink> into a QFlags mask.
    static Sinks maskFromList(std::initializer_list<Sink> sinks){ Sinks m; for(auto s: sinks) m |= s; return m; }

    // Ensures a sink instance exists:
    // - If already present in the registry, returns true.
    // - Else, tries to build it using the registered factory under a mutex.
    // - Warns and returns false if missing or factory returns nullptr.
    bool ensureSink(Sink id) const {
        if (registry_->get(id)) return true;
        QMutexLocker lock(regMutex_.get());
        if (registry_->get(id)) return true;
        auto it = factories_.find(id);
        if (it == factories_.end()) { qWarning() << "[Logger] Cannot create sink: no factory registered for id=:" << int(id); return false; }
        auto ptr = it->second(); if (!ptr) { qWarning() << "[Logger] Cannot create sink: factory returned nullptr for id=" << int(id); return false; }
        registry_->set(id, std::move(ptr));
        return true;
    }

    // Fan-out: writes a record to sinks in a deterministic order if enabled.
    void fanOut(const LogRecord& r, Sinks mask) const {
        // Known sinks; add new ones here (e.g., Rest) to control call order.
        constexpr Sink order[] = { Sink::Console, Sink::SQLiteDB, Sink::Postgres };
        for (Sink id : order){
            if (!mask.testFlag(id)) continue;
            if (!ensureSink(id))    continue;
            if (auto* s = registry_->get(id)) s->write(r);
        }
    }

    // Core logging function: builds LogRecord with context, fields, and source location,
    // resolves the sinks (override or defaults), then fan-outs to sinks.
    void log(LogLevel lvl, const QString& msg,
             std::initializer_list<QPair<QString,QVariant>> f,
             Sinks sinksOverride) const {
        if (static_cast<int>(lvl) < static_cast<int>(minLevel_)) return;

        LogRecord r;
        r.level = lvl;
        r.msg = msg;
        r.context = context_;
        r.tsMs = QDateTime::currentMSecsSinceEpoch();
        r.threadId = QThread::currentThreadId();
        for (auto& p : f) r.fields.insert(p.first, p.second);
        const Sinks resolved = (sinksOverride == Sinks()) ? defaultSinks_ : sinksOverride;
        fanOut(r, resolved);
    }
};

#endif // LOGGER_H
