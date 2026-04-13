#ifndef CONSOLE_SINK_H
#define CONSOLE_SINK_H

#include <QtCore>
#include <QDebug>
#include <QJsonDocument>
#include <QJsonObject>

#include "ILogSink.h"
#include "../core/LogRecord.h"

class ConsoleSink final : public ILogSink {
public:
    explicit ConsoleSink(bool includeThread  = true,
                         bool includeContext = true,
                         bool includeFields  = true);

    void write(const LogRecord& record) override;

private:
    bool m_includeThread;
    bool m_includeContext;
    bool m_includeFields;
};

#endif // CONSOLE_SINK_H
