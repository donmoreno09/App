#ifndef ILOGSINK_H
#define ILOGSINK_H

#include "../core/LogRecord.h"

// Abstract interface for log sinks
// A sink is a target that receives fully-formed log records
class ILogSink {
public:
    virtual ~ILogSink() = default;

    // Write a single log record (must be non-blocking if possible)
    virtual void write(const LogRecord& rec) = 0;

    // Optional: flush buffered data (files, streams, etc.)
    virtual void flush() {}

    virtual void shutdown() {}

protected:
    static QString toJson(const QVariantMap& m) {
        return QString::fromUtf8(QJsonDocument(QJsonObject::fromVariantMap(m)).toJson(QJsonDocument::Compact));
    }
};

#endif // ILOGSINK_H
