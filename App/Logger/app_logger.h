#ifndef APP_LOGGER_H
#define APP_LOGGER_H

#include "app_logger_export.h"
#include "logger.h"
#include "sqlite_sink.h"

class APP_LOGGER_EXPORT AppLogger {
public:
    // Singleton accessor.
    // Creates the Logger on first call and returns the same instance thereafter.
    static Logger& get() {
        static Logger instance = createAndInit();
        return instance;
    }

    // Convenience: flush every registered sink (e.g., commit batched writes) at shutdown.
    static void flush() { get().flush(); }

private:
    // Builds and configures the Logger instance used by the singleton.
    // - Sets default sinks to Console + SQLite
    // - Registers lazy factories for SQLiteDB (and Postgres placeholder)
    // - Optionally "warms up" SQLite to avoid first-log latency
    static Logger createAndInit() {
        auto logger = Logger::create()
        // Default sinks for all logs unless overridden per call:
        .withDefaultSinks({ Sink::Console, Sink::SQLiteDB });

        // Register lazy factories:
        // The sink will be constructed on first use (ensureSink) or explicitly via warmUp/requireSink.
        logger
            .registerSinkFactory(Sink::SQLiteDB, []{
                return std::make_shared<SqliteSink>(
                    Logger::defaultSqlitePath(),  // AppDataLocation/logs.sqlite (platform-specific)
                    /*batch=*/64,                 // commit every 64 inserts
                    /*WAL=*/true,                 // Write-Ahead Logging for performance
                    /*sync=*/true                 // PRAGMA synchronous=NORMAL
                    );
            })
            .registerSinkFactory(Sink::Postgres, []{
                // TODO: replace with a real PostgresSink when available, e.g.:
                // return std::make_shared<PostgresSink>("host=... port=5432 dbname=... user=... password=...");
                return std::shared_ptr<ILogSink>{}; // placeholder keeps the API shape without enabling the sink
            });

        // Optional: pre-create SQLite sink now (avoids cold start on first log line).
        logger.warmUp({ Sink::SQLiteDB });

        return logger;
    }
};

#endif // APP_LOGGER_H
