#include "TruckArrivalService.h"
#include "../TruckArrivalsLogger.h"

#include <QNetworkRequest>
#include <QNetworkReply>
#include <QUrl>
#include <QUrlQuery>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>

namespace {
Logger& _logger()
{
    static Logger logger = TruckArrivalsLogger::get().child({
        {"service", "TRUCK_ARRIVAL_SERVICE"}
    });
    return logger;
}
}

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
    QString kindStr;
    switch (kind) {
    case RequestKind::Today: kindStr = "Today"; break;
    case RequestKind::CurrentHour: kindStr = "CurrentHour"; break;
    case RequestKind::DateRange: kindStr = "DateRange"; break;
    case RequestKind::DateTimeRange: kindStr = "DateTimeRange"; break;
    }

    _logger().info("Sending truck arrivals request", {
        kv("kind", kindStr),
        kv("url", url.toString())
    });

    QNetworkRequest req(url);
    req.setRawHeader("Accept", "application/json");

    QNetworkReply* reply = m_manager.get(req);

    connect(reply, &QNetworkReply::finished, this, [this, reply, kind, kindStr]() {
        const auto finish = qScopeGuard([&] { reply->deleteLater(); });

        if (reply->error() != QNetworkReply::NoError) {
            _logger().warn("Truck arrivals request failed", {
                kv("kind", kindStr),
                kv("error", reply->errorString())
            });
            emit requestFailed(reply->errorString());
            return;
        }

        QByteArray rawData = reply->readAll();

        bool ok = false;
        const int count = rawData.toInt(&ok);

        if (!ok) {
            _logger().warn("Truck arrivals response format was invalid", {
                kv("kind", kindStr),
                kv("response", QString::fromUtf8(rawData))
            });
            emit requestFailed(QStringLiteral("Invalid response format"));
            return;
        }

        emitResult(kind, count, kindStr);
    });
}

void TruckArrivalService::emitResult(RequestKind kind, int count, const QString& kindStr)
{
    _logger().info("Truck arrivals result received", {
        kv("kind", kindStr),
        kv("count", count)
    });

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
    _logger().info("Fetching truck arrivals by date range", {
        kv("start", start.toString(Qt::ISODate)),
        kv("end", end.toString(Qt::ISODate))
    });

    auto url = makeUrl(m_host, m_port, QStringLiteral("/ShipArrivals/GetDateSpanShipArrivals"), [&](QUrlQuery& q) {
        q.addQueryItem(QStringLiteral("startDate"), start.toString(Qt::ISODate));
        q.addQueryItem(QStringLiteral("endDate"),   end.toString(Qt::ISODate));
    });
    performGet(RequestKind::DateRange, url);
}

void TruckArrivalService::getDateTimeRangeArrivals(const QDateTime& start, const QDateTime& end)
{
    _logger().info("Fetching truck arrivals by datetime range", {
        kv("start", start.toString(Qt::ISODate)),
        kv("end", end.toString(Qt::ISODate))
    });

    auto url = makeUrl(m_host, m_port, QStringLiteral("/ShipArrivals/GetDateTimeSpanShipArrivals"), [&](QUrlQuery& q) {
        q.addQueryItem(QStringLiteral("startDateTime"), start.toString(Qt::ISODate));
        q.addQueryItem(QStringLiteral("endDateTime"),   end.toString(Qt::ISODate));
    });
    performGet(RequestKind::DateTimeRange, url);
}
