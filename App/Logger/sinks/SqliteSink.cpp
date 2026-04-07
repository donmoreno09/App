#include "SqliteSink.h"

SqliteSink::SqliteSink(QString dbPath, int batchSize, bool wal, bool syncNormal)
    : m_path(std::move(dbPath))
    , m_batchSize(qMax(1, batchSize))
    , m_wal(wal)
    , m_syncNormal(syncNormal)
    , m_prefix(QStringLiteral("logs_%1_").arg(reinterpret_cast<quintptr>(this), 0, 16)) // UNIQUE per sink
{
    const QString initName = m_prefix + QStringLiteral("init_%1").arg(reinterpret_cast<quintptr>(QThread::currentThreadId()), 0, 16);

    // Use scope block to ensure db handle is destroyed before removeDatabase()
    {
        QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE", initName);
        db.setDatabaseName(m_path);

        if (!db.open()) {
            qWarning() << "SqliteSink: cannot open DB" << m_path << db.lastError();
        } else {
            applyPragmas(db, m_wal, m_syncNormal);
            ensureSchema(db);
        }
    }

    QSqlDatabase::removeDatabase(initName);
}

SqliteSink::~SqliteSink() {
    m_shuttingDown.store(true, std::memory_order_relaxed);
    closeLocal(); // close & remove the current thread’s connection if any
}

void SqliteSink::shutdown() {
    m_shuttingDown.store(true, std::memory_order_relaxed);
    closeLocal(); // current thread

    // Sweep any leftovers for this sink (other threads might have exited already)
    const auto names = QSqlDatabase::connectionNames();
    for (const auto& name : names) {
        if (!name.startsWith(m_prefix)) continue;
        { QSqlDatabase db = QSqlDatabase::database(name, /*open*/false); } // drop handle immediately
        QSqlDatabase::removeDatabase(name);
    }
}

void SqliteSink::write(const LogRecord& r) {
    if (m_shuttingDown.load(std::memory_order_relaxed)) return;

    TLS& tls = threadLocal();
    if (!tls.initialized) initThreadLocal(tls);
    if (!tls.db.isOpen()) {
        qWarning() << "SqliteSink: DB not open in" << tls.connName;
        return;
    }

    if (!tls.inTxn) {
        tls.db.transaction();
        tls.inTxn = true;
        tls.pending = 0;
    }

    tls.insert.bindValue(0, static_cast<qint64>(r.tsMs));
    tls.insert.bindValue(1, static_cast<int>(r.level));
    tls.insert.bindValue(2, 0);
    tls.insert.bindValue(3, QString::number(reinterpret_cast<qulonglong>(r.threadId), 16));
    tls.insert.bindValue(4, r.msg);
    tls.insert.bindValue(5, toJson(r.fields));
    tls.insert.bindValue(6, toJson(r.context));

    if (!tls.insert.exec()) {
        qWarning() << "SqliteSink: insert failed" << tls.insert.lastError();
        tls.db.rollback();
        tls.inTxn = false;
        return;
    }

    if (++tls.pending >= m_batchSize) {
        tls.db.commit();
        tls.inTxn = false;
    }
}

void SqliteSink::flush() {
    TLS& tls = threadLocal();
    if (tls.db.isOpen() && tls.inTxn) {
        tls.db.commit();
        tls.inTxn = false;
    }
}

// ---- TLS ----

SqliteSink::TLS::~TLS() {
    closeAndRemove();
}

void SqliteSink::TLS::closeAndRemove() {
    if (!db.isValid()) return;

    if (inTxn) {
        db.commit();
        inTxn = false;
    }

    insert = QSqlQuery(); // destroy query first
    const auto name = connName;
    db = QSqlDatabase(); // drop last handle

    if (!name.isEmpty()) {
        QSqlDatabase::removeDatabase(name);
    }

    connName.clear();
    initialized = false;
}

// ---- helpers ----

SqliteSink::TLS& SqliteSink::threadLocal() {
    if (!s_tls.hasLocalData()) {
        s_tls.setLocalData(new TLS());
    }

    return *s_tls.localData();
}

void SqliteSink::closeLocal() const {
    if (s_tls.hasLocalData()) s_tls.localData()->closeAndRemove();
}

void SqliteSink::applyPragmas(QSqlDatabase& db, bool wal, bool syncNormal) {
    QSqlQuery q(db);
    if (wal) q.exec("PRAGMA journal_mode=WAL;");
    if (syncNormal) q.exec("PRAGMA synchronous=NORMAL;");
    q.exec("PRAGMA temp_store=MEMORY;");
    q.exec("PRAGMA mmap_size=134217728;");
}

void SqliteSink::ensureSchema(QSqlDatabase& db) {
    QSqlQuery q(db);

    q.exec(R"(CREATE TABLE IF NOT EXISTS logs(
      id INTEGER PRIMARY KEY,
      ts_ms INTEGER NOT NULL,
      ts_iso TEXT GENERATED ALWAYS AS (strftime('%Y-%m-%dT%H:%M:%fZ', ts_ms/1000.0, 'unixepoch')) STORED,
      ts_day TEXT GENERATED ALWAYS AS (strftime('%Y-%m-%d', ts_ms/1000.0, 'unixepoch')) STORED,
      level TINYINT NOT NULL,
      categories INTEGER NOT NULL DEFAULT 0,
      thread_id TEXT, msg TEXT, fields_json TEXT, context_json TEXT);
    )");

    q.exec("CREATE INDEX IF NOT EXISTS idx_logs_ts     ON logs(ts_ms);");
    q.exec("CREATE INDEX IF NOT EXISTS idx_logs_ts_day ON logs(ts_day);");
    q.exec("CREATE INDEX IF NOT EXISTS idx_logs_level  ON logs(level);");
    q.exec("CREATE INDEX IF NOT EXISTS idx_logs_cat    ON logs(categories);");
}

void SqliteSink::initThreadLocal(TLS& tls) const {
    const auto tidHex = QString::number(reinterpret_cast<quintptr>(QThread::currentThreadId()), 16);
    tls.connName = m_prefix + tidHex;

    if (QSqlDatabase::contains(tls.connName)) {
        tls.db = QSqlDatabase::database(tls.connName);
    } else {
        tls.db = QSqlDatabase::addDatabase("QSQLITE", tls.connName);
        tls.db.setDatabaseName(m_path);
    }

    if (!tls.db.isOpen() && !tls.db.open()) {
        qWarning() << "SqliteSink: cannot open DB in" << tls.connName << tls.db.lastError();
    } else {
        applyPragmas(tls.db, m_wal, m_syncNormal);
        tls.insert = QSqlQuery(tls.db);
        tls.insert.prepare(R"(INSERT INTO logs(ts_ms,level,categories,thread_id,msg,fields_json,context_json) VALUES(?,?,?,?,?,?,?))");
    }

    tls.initialized = true;
}
