#ifndef LOG_RECORD_H
#define LOG_RECORD_H

#include "log_types.h"

// Immutable-like record of a single log event
// Can be enriched, filtered, formatted, then dispatched
struct LogRecord {
    // Wall-clock timestamp in ms since epoch
    qint64 tsMs = QDateTime::currentMSecsSinceEpoch();
    // Severity level
    LogLevel level = LogLevel::Info;
    // Human-readable message
    QString msg;
    // Structured, ad-hoc fields (key/value pairs)
    Fields fields;
    // Inherited context (added by parent logger, e.g. userId, session)
    Fields context;
    // Explicit sinks override (per-message routing)
    Sinks sinks = Sinks();
    // Captured thread id
    Qt::HANDLE threadId = QThread::currentThreadId();
};

#endif // LOG_RECORD_H
