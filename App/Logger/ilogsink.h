#ifndef ILOGSINK_H
#define ILOGSINK_H

#include "log_record.h"

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
};

#endif // ILOGSINK_H
