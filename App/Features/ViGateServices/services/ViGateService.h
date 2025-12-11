#pragma once
#include <QObject>
#include <QNetworkAccessManager>
#include <QDateTime>
#include <QJsonObject>
#include <QJsonArray>
#include <QUrl>
#include <QFuture>
#include <QFutureWatcher>

class ViGateService : public QObject
{
    Q_OBJECT
public:
    explicit ViGateService(QObject* parent = nullptr);
    ~ViGateService();

    void setHostPort(const QString& host, int port);

    Q_INVOKABLE void getActiveGates();

    Q_INVOKABLE void getFilteredViGateData(int gateId,
                                           const QDateTime& startDate,
                                           const QDateTime& endDate,
                                           bool pedestrian,
                                           bool vehicle,
                                           int pageNumber = 1,
                                           int pageSize = 50,
                                           const QString& sortBy = QString(),
                                           bool sortDescending = false);

signals:
    void activeGatesReady(const QJsonArray& gates);
    void dataReady(const QJsonObject& data);
    void paginationInfo(int currentPage, int totalPages, int totalItems);
    void requestFailed(const QString& error);
    void notFound();

private slots:
    void onParseFinished();

private:
    QNetworkAccessManager m_manager;
    QString m_host = QStringLiteral("localhost");
    int m_port = 7000;

    // Background processing
    QFutureWatcher<QJsonObject>* m_parseWatcher = nullptr;

    void performGet(const QUrl& url);

    // Static methods for background thread execution
    static QJsonArray transformTransitData(const QJsonArray& transits);
    static QJsonObject parseAndTransformResponse(const QByteArray& responseData);

    static QUrl makeUrl(const QString& host, int port,
                        const QString& path,
                        const std::function<void(QUrlQuery&)>& addQuery = nullptr);
};
