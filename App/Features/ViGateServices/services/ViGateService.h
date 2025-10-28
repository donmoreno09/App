#pragma once
#include <QObject>
#include <QNetworkAccessManager>
#include <QDateTime>
#include <QJsonObject>
#include <QJsonArray>
#include <QUrl>

class ViGateService : public QObject
{
    Q_OBJECT
public:
    explicit ViGateService(QObject* parent = nullptr);

    void setHostPort(const QString& host, int port);

    Q_INVOKABLE void getActiveGates();

    Q_INVOKABLE void getGateData(int gateId,
                                 const QDateTime& startDate,
                                 const QDateTime& endDate,
                                 bool includeVehicles,
                                 bool includePedestrians,
                                 int page = 1,
                                 int pageSize = 50);

signals:
    void activeGatesReady(const QJsonArray& gates);
    void dataReady(const QJsonObject& data);
    void paginationInfo(int currentPage, int totalPages, int totalItems);
    void requestFailed(const QString& error);
    void notFound();

private:
    QNetworkAccessManager m_manager;
    QString m_host = QStringLiteral("localhost");
    int m_port = 7000;

    void performGet(const QUrl& url);

    // Changed return type from QJsonObject to QJsonArray - no longer calculates summary
    QJsonArray transformTransitData(const QJsonArray& transits);

    static QUrl makeUrl(const QString& host, int port,
                        const QString& path,
                        const std::function<void(QUrlQuery&)>& addQuery = nullptr);
};
