#include "ShipArrivalController.h"
#include <QNetworkRequest>
#include <QDebug>
#include <QUrlQuery>

ShipArrivalController::ShipArrivalController(QObject *parent)
    : QObject(parent), m_manager(new QNetworkAccessManager(this))
{
}

bool ShipArrivalController::isLoading() const
{
    return m_loading;
}
int ShipArrivalController::todayArrivalCount() const
{
    return m_todayArrivalCount;
}
int ShipArrivalController::currentHourArrivalCount() const
{
    return m_currentHourArrivalCount;
}
int ShipArrivalController::dateRangeArrivalCount() const
{
    return m_dateRangeArrivalCount;
}
int ShipArrivalController::dateTimeRangeArrivalCount() const
{
    return m_dateTimeRangeArrivalCount;
}

void ShipArrivalController::setLoading(bool loading)
{
    if (m_loading != loading) {
        m_loading = loading;
        emit loadingChanged(loading);
    }
}

void ShipArrivalController::fetchAllArrivalData()
{
    if (m_loading) return;

    m_pendingRequests = 2;
    setLoading(true);

    fetchTodayShipArrivals();
    fetchCurrentHourShipArrivals();
}

void ShipArrivalController::fetchTodayShipArrivals()
{
    QUrl url(QString("http://%1:%2/ShipArrivals/GetTodayShipArrival").arg(m_host).arg(m_port));
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    QNetworkReply *reply = m_manager->get(request);
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        handleNetworkReply(reply, true);
    });
}

void ShipArrivalController::fetchCurrentHourShipArrivals()
{
    QUrl url(QString("http://%1:%2/ShipArrivals/GetCurrentHourShipArrival").arg(m_host).arg(m_port));
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    QNetworkReply *reply = m_manager->get(request);
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        handleNetworkReply(reply, false);
    });
}
void ShipArrivalController::fetchDateRangeShipArrivals(const QDate &startDate, const QDate &endDate)
{
    if (m_loading) return;

    setLoading(true);

    QUrl url(QString("http://%1:%2/ShipArrivals/GetDateSpanShipArrivals").arg(m_host).arg(m_port));

    QUrlQuery query;
    query.addQueryItem("startDate", startDate.toString(Qt::ISODate));
    query.addQueryItem("endDate", endDate.toString(Qt::ISODate));
    url.setQuery(query);

    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    QNetworkReply *reply = m_manager->get(request);
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        if (reply->error() != QNetworkReply::NoError) {
            emit requestFailed(reply->errorString());
            setLoading(false);
            reply->deleteLater();
            return;
        }

        QByteArray response = reply->readAll();
        bool ok;
        int count = response.toInt(&ok);

        if (!ok) {
            emit requestFailed("Invalid response format");
        } else {
            if (m_dateRangeArrivalCount != count) {
                m_dateRangeArrivalCount = count;
                emit dateRangeArrivalCountChanged(count);
            }
            emit dateRangeArrivalsFetched(count);
        }

        setLoading(false);
        reply->deleteLater();
    });
}
void ShipArrivalController::fetchDateTimeRangeShipArrivals(const QDateTime &startDateTime, const QDateTime &endDateTime)
{
    if (m_loading) return;

    setLoading(true);

    QUrl url(QString("http://%1:%2/ShipArrivals/GetDateTimeSpanShipArrivals").arg(m_host).arg(m_port));

    QUrlQuery query;
    query.addQueryItem("startDateTime", startDateTime.toString(Qt::ISODate));
    query.addQueryItem("endDateTime", endDateTime.toString(Qt::ISODate));
    url.setQuery(query);

    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    QNetworkReply *reply = m_manager->get(request);
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        if (reply->error() != QNetworkReply::NoError) {
            emit requestFailed(reply->errorString());
            setLoading(false);
            reply->deleteLater();
            return;
        }

        QByteArray response = reply->readAll();
        bool ok;
        int count = response.toInt(&ok);

        if (!ok) {
            emit requestFailed("Invalid response format");
        } else {
            if (m_dateTimeRangeArrivalCount != count) {
                m_dateTimeRangeArrivalCount = count;
                emit dateTimeRangeArrivalCountChanged(count);
            }
        }

        setLoading(false);
        reply->deleteLater();
    });
}
void ShipArrivalController::handleNetworkReply(QNetworkReply *reply, bool isTodayRequest)
{
    if (reply->error() != QNetworkReply::NoError) {
        emit requestFailed(reply->errorString());
        reply->deleteLater();

        if (--m_pendingRequests == 0) {
            setLoading(false);
        }
        return;
    }

    QByteArray response = reply->readAll();
    bool ok;
    int count = response.toInt(&ok);

    if (!ok) {
        emit requestFailed("Invalid response format");
        reply->deleteLater();

        if (--m_pendingRequests == 0) {
            setLoading(false);
        }
        return;
    }

    if (isTodayRequest) {
        if (m_todayArrivalCount != count) {
            m_todayArrivalCount = count;
            emit todayArrivalCountChanged(count);
        }
        emit todayArrivalsFetched(count);
    } else {
        if (m_currentHourArrivalCount != count) {
            m_currentHourArrivalCount = count;
            emit currentHourArrivalCountChanged(count);
        }
        emit currentHourArrivalsFetched(count);
    }

    reply->deleteLater();

    if (--m_pendingRequests == 0) {
        setLoading(false);
    }
}
