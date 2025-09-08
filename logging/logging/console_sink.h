#ifndef CONSOLE_SINK_H
#define CONSOLE_SINK_H

#include <QtCore>
#include <QDebug>
#include <QJsonDocument>
#include <QJsonObject>
#include "ilogsink.h"
#include "log_record.h"
#include "log_types.h"

class ConsoleSink final : public ILogSink {
public:
    explicit ConsoleSink(bool includeThread   = true,
                         bool includeContext  = true,
                         bool includeFields   = true)
        : includeThread_(includeThread)
        , includeContext_(includeContext)
        , includeFields_(includeFields)
    {}

    void write(const LogRecord& r) override {
        QStringList parts;
        parts << QDateTime::fromMSecsSinceEpoch(r.tsMs).toString(Qt::ISODateWithMs)
              << QStringLiteral("[%1]").arg(levelToCStr(r.level))
              << r.msg;

        if (includeContext_ && !r.context.isEmpty())
            parts << QStringLiteral("ctx=%1").arg(toJson(r.context));
        if (includeFields_ && !r.fields.isEmpty())
            parts << QStringLiteral("fields=%1").arg(toJson(r.fields));
        if (includeThread_) {
            auto tid = reinterpret_cast<quintptr>(r.threadId);
            parts << QStringLiteral("thr=%1").arg(QString::number(tid, 16));
        }
        const QString line = parts.join(' ');
        switch (r.level) {
        case LogLevel::Info:  qInfo().noquote()     << line; break;
        case LogLevel::Warn:  qWarning().noquote()  << line; break;
        case LogLevel::Error: qCritical().noquote() << line; break;
        }
    }
private:
    bool includeThread_;
    bool includeContext_;
    bool includeFields_;
    static QString toJson(const QVariantMap& m) {
        return QString::fromUtf8(QJsonDocument(QJsonObject::fromVariantMap(m))
                                     .toJson(QJsonDocument::Compact));
    }
};



#endif // CONSOLE_SINK_H
