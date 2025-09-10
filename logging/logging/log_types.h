#ifndef LOG_TYPES_H
#define LOG_TYPES_H

#include <QtCore>

// Scoped, compact log level
enum class LogLevel : quint8 { Info=0, Warn=1, Error=2 };

// Bitmask flags for output targets
enum Sink : quint32 {
    Console     = 1u << 0,
    SQLiteDB    = 1u << 1,
    Rest        = 1u << 2,
    Postgres    = 1u << 3
};

Q_DECLARE_FLAGS(Sinks, Sink)
Q_DECLARE_OPERATORS_FOR_FLAGS(Sinks)

// Fast C-string mapping for levels (for printf/qDebug)
inline const char* levelToCStr(LogLevel l) {
    switch(l) {
    case LogLevel::Info: return "INFO";
    case LogLevel::Warn: return "WARN";
    case LogLevel::Error:return "ERROR";
    }
    return "INFO";
}

// Key/value helpers for structured fields
using Fields = QVariantMap;

// Tiny helper to build pairs inline
inline QPair<QString,QVariant> kv(QString k, QVariant v){ return {std::move(k), std::move(v)}; }

#endif // LOG_TYPES_H
