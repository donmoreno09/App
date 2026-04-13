#include "ConsoleSink.h"

ConsoleSink::ConsoleSink(bool includeThread, bool includeContext, bool includeFields)
    : m_includeThread(includeThread)
    , m_includeContext(includeContext)
    , m_includeFields(includeFields)
{}

void ConsoleSink::write(const LogRecord& record) {
    const QString ts = QDateTime::fromMSecsSinceEpoch(record.tsMs).toString(Qt::ISODateWithMs);
    const QString service = record.context.value("service", "APP").toString();

    QString thread;
    if (m_includeThread) {
        const auto tid = reinterpret_cast<quintptr>(record.threadId);
        thread = QString::number(tid, 16);
    }

    const QString tag = QStringLiteral("[%1:%2%3]")
                            .arg(levelToCStr(record.level),
                                 service,
                                 thread.isEmpty() ? QString() : ":" + thread);

    QStringList parts;
    parts << paint(ts, AnsiColor::Blue)
          << QStringLiteral(" ")
          << paint(tag, levelColor(record.level))
          << QStringLiteral(" ")
          << record.msg;

    if (m_includeContext && !record.context.isEmpty()) {
        parts << "\n\t" << QStringLiteral("ctx=%1").arg(toJson(record.context));
    }

    if (m_includeFields && !record.fields.isEmpty()) {
        parts << "\n\t" << QStringLiteral("fields=%1").arg(toJson(record.fields));
    }

    const QString line = parts.join("");

    switch (record.level) {
    case LogLevel::Info:  qInfo().noquote()    << line; break;
    case LogLevel::Warn:  qWarning().noquote() << line; break;
    case LogLevel::Error: qCritical().noquote()<< line; break;
    }
}
