#include "TruckArrivalService.h"

#include <QNetworkRequest>
#include <QNetworkReply>
#include <QUrl>
#include <QUrlQuery>

TruckArrivalService::TruckArrivalService(QObject* parent)
    : QObject(parent)
{
}

void TruckArrivalService::setHostPort(const QString& host, int port)
{
    m_host = host;
    m_port = port;
}

QUrl TruckArrivalService::makeUrl(const QString& host, int port,
                                 const QString& path,
                                 const std::function<void(QUrlQuery&)>& addQuery)
{
    QUrl url(QStringLiteral("http://%1:%2%3").arg(host).arg(port).arg(path));
    if (addQuery) {
        QUrlQuery q;
        addQuery(q);
        url.setQuery(q);
    }
    return url;
}

void TruckArrivalService::performGet(RequestKind kind, const QUrl& url)
{
    QNetworkRequest req(url);
    req.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    QNetworkReply* reply = m_manager.get(req);
    connect(reply, &QNetworkReply::finished, this, [this, reply, kind]() {
        const auto finish = qScopeGuard([&] { reply->deleteLater(); });

        if (reply->error() != QNetworkReply::NoError) {
            emit requestFailed(reply->errorString());
            return;
        }

        bool ok = false;
        const int count = reply->readAll().toInt(&ok);
        if (!ok) {
            emit requestFailed(QStringLiteral("Invalid response format"));
            return;
        }

        switch (kind) {
        case RequestKind::Today:
            emit todayArrivalsReady(count);
            break;
        case RequestKind::CurrentHour:
            emit currentHourArrivalsReady(count);
            break;
        case RequestKind::DateRange:
            emit dateRangeArrivalsReady(count);
            break;
        case RequestKind::DateTimeRange:
            emit dateTimeRangeArrivalsReady(count);
            break;
        }
    });
}

void TruckArrivalService::getTodayArrivals()
{
    auto url = makeUrl(m_host, m_port, QStringLiteral("/ShipArrivals/GetTodayShipArrival"));
    performGet(RequestKind::Today, url);
}

void TruckArrivalService::getCurrentHourArrivals()
{
    auto url = makeUrl(m_host, m_port, QStringLiteral("/ShipArrivals/GetCurrentHourShipArrival"));
    performGet(RequestKind::CurrentHour, url);
}

void TruckArrivalService::getDateRangeArrivals(const QDate& start, const QDate& end)
{
    auto url = makeUrl(m_host, m_port, QStringLiteral("/ShipArrivals/GetDateSpanShipArrivals"),
                       [&](QUrlQuery& q) {
                           q.addQueryItem(QStringLiteral("startDate"), start.toString(Qt::ISODate));
                           q.addQueryItem(QStringLiteral("endDate"),   end.toString(Qt::ISODate));
                       });
    performGet(RequestKind::DateRange, url);
}

void TruckArrivalService::getDateTimeRangeArrivals(const QDateTime& start, const QDateTime& end)
{
    auto url = makeUrl(m_host, m_port, QStringLiteral("/ShipArrivals/GetDateTimeSpanShipArrivals"),
                       [&](QUrlQuery& q) {
                           q.addQueryItem(QStringLiteral("startDateTime"), start.toString(Qt::ISODate));
                           q.addQueryItem(QStringLiteral("endDateTime"),   end.toString(Qt::ISODate));
                       });
    performGet(RequestKind::DateTimeRange, url);
}
