#ifndef SQLITE_SINK_H
#define SQLITE_SINK_H

#include <QtCore>
#include <QtSql>
#include <QJsonDocument>
#include <QJsonObject>
#include <atomic>

#include "ILogSink.h"
#include "../core/LogRecord.h"

class SqliteSink final : public ILogSink {
public:
    explicit SqliteSink(QString dbPath, int batchSize = 64, bool wal = true, bool syncNormal = true);
    ~SqliteSink() override;

    void shutdown() override;

    void write(const LogRecord& r) override;

    void flush() override;

private:
    // ----- shared -----
    const QString m_path;
    const int m_batchSize;
    const bool m_wal;
    const bool m_syncNormal;
    const QString m_prefix;
    std::atomic_bool m_shuttingDown{false};

    // ----- per-thread -----
    struct TLS {
        QString connName;
        QSqlDatabase db;
        QSqlQuery insert;
        bool initialized = false;
        bool inTxn = false;
        int pending = 0;

        ~TLS();

        void closeAndRemove();
    };

    inline static QThreadStorage<TLS*> s_tls{}; // one TLS (Thread Local Storage) per thread, auto-deleted at thread exit

    static TLS& threadLocal();

    void closeLocal() const;

    static void applyPragmas(QSqlDatabase& db, bool wal, bool syncNormal);

    static void ensureSchema(QSqlDatabase& db);

    void initThreadLocal(TLS& tls) const;
};

#endif // SQLITE_SINK_H
