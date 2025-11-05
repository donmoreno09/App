#ifndef CSVTABLEMODEL_H
#define CSVTABLEMODEL_H

#include <QAbstractTableModel>
#include <QQmlEngine>

class CsvTableModel : public QAbstractTableModel {
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(bool loading READ loading NOTIFY loadingChanged)

public:
    explicit CsvTableModel(QObject* parent=nullptr);

    int rowCount(const QModelIndex&) const override;
    int columnCount(const QModelIndex&) const override;

    QVariant data(const QModelIndex& i, int role) const override;
    QVariant headerData(int s, Qt::Orientation o, int role) const override;

    Q_INVOKABLE void load(const QUrl& url, const QStringList& ignoreColumns);

    Q_INVOKABLE int findColumn(const QString& name) const;

    bool loading() const { return m_loading; }

signals:
    void loadingChanged();
    void headerChanged();

private slots:
    void onHeaderReady(const QStringList &headers, const QVector<int> &keep);
    void onRowsReady(const QVector<QStringList> &chunk);
    void onFinished();

private:
    int m_rows = 0;
    int m_cols = 0;
    QStringList m_headers;
    QVector<QVector<QString>> m_data;
    bool m_loading=false;

    static QString resolvePathForQFile(const QUrl& url);
};

#endif // CSVTABLEMODEL_H
