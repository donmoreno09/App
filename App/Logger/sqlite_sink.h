#ifndef SQLITE_SINK_H
#define SQLITE_SINK_H

#include <QtCore>
#include <QtSql>
#include <QJsonDocument>
#include <QJsonObject>
#include "ilogsink.h"
#include "log_record.h"

// sqlite_sink.h  (only the relevant diffs)

class SqliteSink final : public ILogSink {
public:
    explicit SqliteSink(QString dbPath, int batchSize=64, bool wal=true, bool syncNormal=true)
        : path_(std::move(dbPath)), batchSize_(qMax(1,batchSize)), wal_(wal), syncNormal_(syncNormal),
        prefix_(QStringLiteral("logs_%1_").arg(reinterpret_cast<quintptr>(this), 0, 16))  // UNIQUE per sink
    {
        const QString initName = prefix_ + QStringLiteral("init_%1")
        .arg(reinterpret_cast<quintptr>(QThread::currentThreadId()), 0, 16);
        {   QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE", initName);
            db.setDatabaseName(path_);
            if (!db.open()) qWarning() << "SqliteSink: cannot open DB" << path_ << db.lastError();
            else { applyPragmas(db, wal_, syncNormal_); ensureSchema(db); }
        }
        QSqlDatabase::removeDatabase(initName);   // correct pattern; local db is out of scope.  See docs.
    }

    ~SqliteSink() override {
        shuttingDown_.store(true, std::memory_order_relaxed);
        closeLocal();   // close & remove the current thread’s connection if any
    }

    void shutdown() override {
        shuttingDown_.store(true, std::memory_order_relaxed);
        closeLocal();   // current thread

        // Sweep any leftovers for this sink (other threads might have exited already)
        const auto names = QSqlDatabase::connectionNames();
        for (const auto& name : names) {
            if (!name.startsWith(prefix_)) continue;
            { QSqlDatabase db = QSqlDatabase::database(name, /*open*/false); } // drop handle immediately
            QSqlDatabase::removeDatabase(name);  // thread-safe
        }
    }

    void write(const LogRecord& r) override {
        if (shuttingDown_.load(std::memory_order_relaxed)) return;
        TLS& tls = threadLocal();
        if (!tls.initialized) initThreadLocal(tls);
        if (!tls.db.isOpen()) { qWarning() << "SqliteSink: DB not open in" << tls.connName; return; }

        if (!tls.inTxn) { tls.db.transaction(); tls.inTxn = true; tls.pending = 0; }

        tls.insert.bindValue(0, static_cast<qint64>(r.tsMs));
        tls.insert.bindValue(1, static_cast<int>(r.level));
        tls.insert.bindValue(2, 0);
        tls.insert.bindValue(3, QString::number(reinterpret_cast<qulonglong>(r.threadId), 16));
        tls.insert.bindValue(4, r.msg);
        tls.insert.bindValue(5, toJson(r.fields));
        tls.insert.bindValue(6, toJson(r.context));
        if (!tls.insert.exec()) {
            qWarning() << "SqliteSink: insert failed" << tls.insert.lastError();
            tls.db.rollback(); tls.inTxn=false; return;
        }
        if (++tls.pending >= batchSize_) { tls.db.commit(); tls.inTxn=false; }
    }

    void flush() override {
        TLS& tls = threadLocal();
        if (tls.db.isOpen() && tls.inTxn) { tls.db.commit(); tls.inTxn=false; }
    }

private:
    // ----- shared -----
    const QString path_;
    const int     batchSize_;
    const bool    wal_;
    const bool    syncNormal_;
    const QString prefix_;
    std::atomic_bool shuttingDown_{false};

    // ----- per-thread (managed via QThreadStorage) -----
    struct TLS {
        QString connName;
        QSqlDatabase db;
        QSqlQuery    insert;
        bool         initialized = false;
        bool         inTxn       = false;
        int          pending     = 0;

        ~TLS() { closeAndRemove(); }  // run in the owning thread at thread exit

        void closeAndRemove() {
            if (!db.isValid()) return;
            if (inTxn) { db.commit(); inTxn = false; }
            insert = QSqlQuery();      // destroy query first
            const auto name = connName;
            db = QSqlDatabase();       // drop last handle
            if (!name.isEmpty()) QSqlDatabase::removeDatabase(name);  // finally remove
            connName.clear();
            initialized = false;
        }
    };

    static QThreadStorage<TLS*> tls_;  // one TLS per thread, auto-deleted at thread exit

    static TLS& threadLocal() {
        if (!tls_.hasLocalData()) tls_.setLocalData(new TLS());
        return *tls_.localData();
    }

    void closeLocal() const {           // helper for ~SqliteSink and shutdown()
        if (tls_.hasLocalData()) tls_.localData()->closeAndRemove();
    }

    static QString toJson(const QVariantMap& m){
        return QString::fromUtf8(QJsonDocument(QJsonObject::fromVariantMap(m)).toJson(QJsonDocument::Compact));
    }
    static void applyPragmas(QSqlDatabase& db, bool wal, bool syncNormal){
        QSqlQuery q(db);
        if (wal) q.exec("PRAGMA journal_mode=WAL;");
        if (syncNormal) q.exec("PRAGMA synchronous=NORMAL;");
        q.exec("PRAGMA temp_store=MEMORY;");
        q.exec("PRAGMA mmap_size=134217728;");
    }
    static void ensureSchema(QSqlDatabase& db){
        QSqlQuery q(db);
        q.exec(R"(CREATE TABLE IF NOT EXISTS logs(
          id INTEGER PRIMARY KEY,
          ts_ms INTEGER NOT NULL,
          ts_iso TEXT GENERATED ALWAYS AS (strftime('%Y-%m-%dT%H:%M:%fZ', ts_ms/1000.0, 'unixepoch')) STORED,
          ts_day TEXT GENERATED ALWAYS AS (strftime('%Y-%m-%d', ts_ms/1000.0, 'unixepoch')) STORED,
          level TINYINT NOT NULL,
          categories INTEGER NOT NULL DEFAULT 0,
          thread_id TEXT, msg TEXT, fields_json TEXT, context_json TEXT);)");
        q.exec("CREATE INDEX IF NOT EXISTS idx_logs_ts     ON logs(ts_ms);");
        q.exec("CREATE INDEX IF NOT EXISTS idx_logs_ts_day ON logs(ts_day);");
        q.exec("CREATE INDEX IF NOT EXISTS idx_logs_level  ON logs(level);");
        q.exec("CREATE INDEX IF NOT EXISTS idx_logs_cat    ON logs(categories);");
    }

    void initThreadLocal(TLS& tls) const {
        const auto tidHex = QString::number(reinterpret_cast<quintptr>(QThread::currentThreadId()), 16);
        tls.connName = prefix_ + tidHex;
        if (QSqlDatabase::contains(tls.connName)) tls.db = QSqlDatabase::database(tls.connName);
        else { tls.db = QSqlDatabase::addDatabase("QSQLITE", tls.connName); tls.db.setDatabaseName(path_); }
        if (!tls.db.isOpen() && !tls.db.open()) {
            qWarning() << "SqliteSink: cannot open DB in" << tls.connName << tls.db.lastError();
        } else {
            applyPragmas(tls.db, wal_, syncNormal_);
            tls.insert = QSqlQuery(tls.db);
            tls.insert.prepare(R"(INSERT INTO logs(ts_ms,level,categories,thread_id,msg,fields_json,context_json)
                                 VALUES(?,?,?,?,?,?,?))");
        }
        tls.initialized = true;
    }
};

QThreadStorage<SqliteSink::TLS*> SqliteSink::tls_;

#endif // SQLITE_SINK_H
