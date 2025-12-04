#pragma once

#include <QObject>
#include <QNetworkAccessManager>
#include <QDate>
#include <QDateTime>
#include <QUrl>

class TruckArrivalService : public QObject
{
    Q_OBJECT
public:
    explicit TruckArrivalService(QObject* parent = nullptr);

    void setHostPort(const QString& host, int port);

    Q_INVOKABLE void getTodayArrivals();
    Q_INVOKABLE void getCurrentHourArrivals();
    Q_INVOKABLE void getDateRangeArrivals(const QDate& start, const QDate& end);
    Q_INVOKABLE void getDateTimeRangeArrivals(const QDateTime& start, const QDateTime& end);

signals:
    void todayArrivalsReady(int count);
    void currentHourArrivalsReady(int count);
    void dateRangeArrivalsReady(int count);
    void dateTimeRangeArrivalsReady(int count);
    void requestFailed(const QString& error);

private:
    enum class RequestKind { Today, CurrentHour, DateRange, DateTimeRange };

    QNetworkAccessManager m_manager;
    QString m_host = QStringLiteral("localhost");
    int m_port = 5002;

    void performGet(RequestKind kind, const QUrl& url);
    void emitResult(RequestKind kind, int count, const QString& kindStr);
    static QUrl makeUrl(const QString& host, int port, const QString& path, const std::function<void(QUrlQuery&)>& addQuery = nullptr);
};
