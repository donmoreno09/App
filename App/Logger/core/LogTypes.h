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

// Tiny helper to build pairs inline
inline QPair<QString,QVariant> kv(QString k, QVariant v){ return {std::move(k), std::move(v)}; }

// Console color handling
namespace AnsiColor {
static constexpr const char* Reset  = "\x1b[0m";
static constexpr const char* Black   = "\x1b[30m";
static constexpr const char* Red     = "\x1b[31m";
static constexpr const char* Green   = "\x1b[32m";
static constexpr const char* Yellow  = "\x1b[33m";
static constexpr const char* Blue    = "\x1b[34m";
static constexpr const char* Magenta = "\x1b[35m";
static constexpr const char* Cyan    = "\x1b[36m";
static constexpr const char* White   = "\x1b[37m";
}

static const char* levelColor(LogLevel level) {
    switch (level) {
    case LogLevel::Info: return AnsiColor::Green;
    case LogLevel::Warn: return AnsiColor::Yellow;
    case LogLevel::Error: return AnsiColor::Red;
    }
    return AnsiColor::Reset;
}

static QString paint(const QString& str, const char* ansi) {
    return QString::fromLatin1(ansi) + str + QString::fromLatin1(AnsiColor::Reset);
}

#endif // LOG_TYPES_H
