// CsvTableModel.cpp (core ideas only)
#include "CsvTableModel.h"
#include <QFile>
#include <QThread>
#include <QtConcurrent>

static QStringList splitRow(const QString& line) {
    return line.split(';', Qt::KeepEmptyParts);
}

CsvTableModel::CsvTableModel(QObject* p): QAbstractTableModel(p) {}

CsvTableModel::~CsvTableModel()
{
    m_cancel.store(true, std::memory_order_relaxed);
    if (m_future.isRunning()) {
        m_future.waitForFinished();
    }
}

int CsvTableModel::rowCount(const QModelIndex &) const
{
    return m_rows;
}

int CsvTableModel::columnCount(const QModelIndex &) const
{
    return m_cols;
}

void CsvTableModel::load(const QUrl& url, const QStringList& ignore) {
    if (m_loading) {
        return;
    }

    m_loading = true;
    emit loadingChanged();

    m_cancel.store(false, std::memory_order_relaxed);

    const QString path = resolvePathForQFile(url);
    if (path.isEmpty()) {
        onFinished();
        return;
    }

    m_future = QtConcurrent::run([this, path, ignore]() {
        QFile file(path);
        if (!file.open(QIODevice::ReadOnly)) {
            QMetaObject::invokeMethod(this, [this]() { onFinished(); }, Qt::QueuedConnection);
            return;
        }

        QStringList headers = QString::fromUtf8(file.readLine()).trimmed().split(';', Qt::KeepEmptyParts);

        QVector<int> keep;
        keep.reserve(headers.size());

        for (int i = 0; i < headers.size(); ++i) {
            bool drop = false;

            for (const auto& ig : ignore) {
                if (headers[i].compare(ig, Qt::CaseInsensitive) == 0) {
                    drop = true;
                    break;
                }
            }

            if (!drop) {
                keep.push_back(i);
            }
        }

        if (m_cancel.load(std::memory_order_relaxed)) {
            // cancelled before we even start pushing rows
            QMetaObject::invokeMethod(this, [this]() { onFinished(); }, Qt::QueuedConnection);
            return;
        }

        // Post header handling back to GUI thread
        QMetaObject::invokeMethod(this, [this, headers, keep]() {
            onHeaderReady(headers, keep);
        }, Qt::QueuedConnection);

        // Parse rows in chunks
        QVector<QStringList> chunk;
        chunk.reserve(500);

        while (!file.atEnd()) {
            if (m_cancel.load(std::memory_order_relaxed))
                break;

            const QString line = QString::fromUtf8(file.readLine());
            if (line.trimmed().isEmpty())
                continue;

            const auto cells = splitRow(line);

            QStringList filtered;
            filtered.reserve(keep.size());
            for (int i = 0; i < keep.size(); ++i) {
                const int k = keep[i];
                filtered << (k < cells.size() ? cells[k].trimmed() : QString());
            }

            chunk.push_back(std::move(filtered));

            if (chunk.size() == 500) {
                // copy chunk to send to GUI thread
                auto toSend = chunk;
                QMetaObject::invokeMethod(this, [this, toSend]() {
                    onRowsReady(toSend);
                }, Qt::QueuedConnection);
                chunk.clear();
            }
        }

        if (!chunk.isEmpty() && !m_cancel.load(std::memory_order_relaxed)) {
            auto toSend = chunk;
            QMetaObject::invokeMethod(this, [this, toSend]() {
                onRowsReady(toSend);
            }, Qt::QueuedConnection);
        }

        QMetaObject::invokeMethod(this, [this]() { onFinished(); }, Qt::QueuedConnection);
    });
}

int CsvTableModel::findColumn(const QString& name) const {
    for (int i = 0; i < m_headers.size(); i++) {
        if (m_headers[i].compare(name, Qt::CaseInsensitive) == 0) {
            return i;
        }
    }

    return -1;
}

void CsvTableModel::onHeaderReady(const QStringList &headers, const QVector<int> &keep) {
    beginResetModel();
    m_headers.clear();

    for (int i = 0; i < keep.size(); i++) {
        auto k = keep[i];
        m_headers << headers[k].trimmed().replace('_',' ').replace(QRegularExpression("([a-z])([A-Z])"), "\\1 \\2");
    }

    m_cols = m_headers.size();

    m_data.clear();
    endResetModel();
    emit headerChanged();
}

void CsvTableModel::onRowsReady(const QVector<QStringList> &chunk) {
    const int start = m_rows;
    const int end = m_rows + chunk.size() - 1;

    beginInsertRows(QModelIndex(), start, end);
    m_data.reserve(m_rows + chunk.size());

    for (auto& row: chunk) {
        QVector<QString> v;
        v.reserve(row.size());

        for (auto& s: row) {
            v << s;
        }

        m_data << std::move(v);
    }

    m_rows = m_data.size();
    endInsertRows();

    // First chunk loaded, so tell GUI that it can show it now
    if (m_loading) {
        m_loading = false;
        emit loadingChanged();
    }
}

QVariant CsvTableModel::data(const QModelIndex& i, int role) const {
    if (!i.isValid() || role != Qt::DisplayRole)
        return {};

    return (i.column() < m_data[i.row()].size() ? m_data[i.row()][i.column()] : QString());
}

QVariant CsvTableModel::headerData(int s, Qt::Orientation orientation, int role) const {
    if (orientation == Qt::Horizontal && role == Qt::DisplayRole && s < m_headers.size())
        return m_headers[s];

    return {};
}

void CsvTableModel::onFinished() {
    m_loading = false;
    emit loadingChanged();
}

QString CsvTableModel::resolvePathForQFile(const QUrl &url)
{
    if (url.isLocalFile()) {
        return url.toLocalFile();
    }

    const auto scheme = url.scheme().toLower();

    if (scheme == "qrc") {
        QString p = url.path();
        if (p.startsWith('/')) p.remove(0,1);
        return QStringLiteral(":/") + p;
    }

    if (scheme.isEmpty()) {
        const QString s = url.toString();
        if (s.startsWith(":/"))
            return s;
    }

    return QString();
}
