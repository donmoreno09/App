#include "TruckArrivalService.h"

#include <QNetworkRequest>
#include <QNetworkReply>
#include <QUrl>
#include <QUrlQuery>
#include <QDebug>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>

TruckArrivalService::TruckArrivalService(QObject* parent)
    : QObject(parent)
{
    // qDebug() << "[TruckArrivalService] Initialized with host:" << m_host << "port:" << m_port;
}

void TruckArrivalService::setHostPort(const QString& host, int port)
{
    m_host = host;
    m_port = port;
    // qDebug() << "[TruckArrivalService] Host/Port set to:" << m_host << ":" << m_port;
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
    // qDebug() << "[TruckArrivalService] Generated URL:" << url.toString();
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

    qDebug() << "[TruckArrivalService] Starting" << kindStr << "request to:" << url.toString();

    QNetworkRequest req(url);
    req.setRawHeader("Accept", "application/json");

    // qDebug() << "========== REQUEST DEBUG ==========";
    // qDebug() << "URL:" << url.toString();
    // qDebug() << "URL Query:" << url.query();
    // qDebug() << "URL Path:" << url.path();

    QNetworkReply* reply = m_manager.get(req);

    connect(reply, &QNetworkReply::finished, this, [this, reply, kind, kindStr]() {
        const auto finish = qScopeGuard([&] { reply->deleteLater(); });

        // qDebug() << "[TruckArrivalService]" << kindStr << "- Reply received";
        // qDebug() << "[TruckArrivalService]" << kindStr << "- HTTP Status:" << reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
        // qDebug() << "[TruckArrivalService]" << kindStr << "- Error:" << reply->error() << reply->errorString();

        if (reply->error() != QNetworkReply::NoError) {
            qWarning() << "[TruckArrivalService]" << kindStr << "- Request failed:" << reply->errorString();
            emit requestFailed(reply->errorString());
            return;
        }

        QByteArray rawData = reply->readAll();

        // qDebug() << "========== RESPONSE DEBUG ==========";
        // qDebug() << "HTTP Status Code:" << reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
        // qDebug() << "Content-Type:" << reply->header(QNetworkRequest::ContentTypeHeader).toString();
        // qDebug() << "Raw Response (text):" << rawData;
        // qDebug() << "Raw Response (hex):" << rawData.toHex();
        // qDebug() << "Response size (bytes):" << rawData.size();
        // qDebug() << "====================================";

        bool ok = false;
        const int count = rawData.toInt(&ok);

        if (!ok) {
            // qWarning() << "[TruckArrivalService]" << kindStr << "- Invalid response format - not JSON and not integer";
            // qWarning() << "[TruckArrivalService]" << kindStr << "- Raw data (hex):" << rawData.toHex();
            emit requestFailed(QStringLiteral("Invalid response format"));
            return;
        }

        // qDebug() << "[TruckArrivalService]" << kindStr << "- Parsed as integer:" << count;
        emitResult(kind, count, kindStr);
    });
}

void TruckArrivalService::emitResult(RequestKind kind, int count, const QString& kindStr)
{
    qDebug() << "[TruckArrivalService]" << kindStr << "- Emitting signal with count:" << count;

    switch (kind) {
    case RequestKind::Today:
        emit todayArrivalsReady(count);
        qDebug() << "[TruckArrivalService] todayArrivalsReady(" << count << ") signal emitted";
        break;
    case RequestKind::CurrentHour:
        emit currentHourArrivalsReady(count);
        qDebug() << "[TruckArrivalService] currentHourArrivalsReady(" << count << ") signal emitted";
        break;
    case RequestKind::DateRange:
        emit dateRangeArrivalsReady(count);
        qDebug() << "[TruckArrivalService] dateRangeArrivalsReady(" << count << ") signal emitted";
        break;
    case RequestKind::DateTimeRange:
        emit dateTimeRangeArrivalsReady(count);
        qDebug() << "[TruckArrivalService] dateTimeRangeArrivalsReady(" << count << ") signal emitted";
        break;
    }
}

void TruckArrivalService::getTodayArrivals()
{
    // qDebug() << "[TruckArrivalService] getTodayArrivals() called";
    auto url = makeUrl(m_host, m_port, QStringLiteral("/ShipArrivals/GetTodayShipArrival"));
    performGet(RequestKind::Today, url);
}

void TruckArrivalService::getCurrentHourArrivals()
{
    // qDebug() << "[TruckArrivalService] getCurrentHourArrivals() called";
    auto url = makeUrl(m_host, m_port, QStringLiteral("/ShipArrivals/GetCurrentHourShipArrival"));
    performGet(RequestKind::CurrentHour, url);
}

void TruckArrivalService::getDateRangeArrivals(const QDate& start, const QDate& end)
{
    qDebug() << "[TruckArrivalService] getDateRangeArrivals() called with:" << start << "to" << end;
    auto url = makeUrl(m_host, m_port, QStringLiteral("/ShipArrivals/GetDateSpanShipArrivals"),
                       [&](QUrlQuery& q) {
                           q.addQueryItem(QStringLiteral("startDate"), start.toString(Qt::ISODate));
                           q.addQueryItem(QStringLiteral("endDate"),   end.toString(Qt::ISODate));
                       });
    performGet(RequestKind::DateRange, url);
}

void TruckArrivalService::getDateTimeRangeArrivals(const QDateTime& start, const QDateTime& end)
{
    qDebug() << "[TruckArrivalService] getDateTimeRangeArrivals() called with:" << start << "to" << end;
    auto url = makeUrl(m_host, m_port, QStringLiteral("/ShipArrivals/GetDateTimeSpanShipArrivals"),
                       [&](QUrlQuery& q) {
                           q.addQueryItem(QStringLiteral("startDateTime"), start.toString(Qt::ISODate));
                           q.addQueryItem(QStringLiteral("endDateTime"),   end.toString(Qt::ISODate));
                       });
    performGet(RequestKind::DateTimeRange, url);
}
