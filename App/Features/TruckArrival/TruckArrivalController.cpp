#include "TruckArrivalController.h"
#include <QNetworkRequest>
#include <QUrlQuery>
#include <QJsonDocument>

TruckArrivalController::TruckArrivalController(QObject *parent)
    : QObject(parent)
    , m_network(new QNetworkAccessManager(this))
    , m_baseUrl("http://localhost:5002") // Default
{
}

void TruckArrivalController::setBaseUrl(const QUrl &url)
{
    if (m_baseUrl != url) {
        m_baseUrl = url;
        emit baseUrlChanged();
    }
}

void TruckArrivalController::setModel(TruckArrivalModel *m)
{
    if(m_model == m) return;
    m_model = m;
    emit modelChanged();
}

void TruckArrivalController::fetchTodayCount()
{
    makeRequest("ShipArrivals/GetTodayShipArrival", {}, [this](const QByteArray &data) {
        bool ok;
        int count = data.toInt(&ok);
        if (ok) {
            if (m_todayCount != count) { m_todayCount = count; emit todayCountChanged(); }
            m_lastError.clear();
        } else {
            setError("Invalid response format");
        }
    });
}

void TruckArrivalController::fetchCurrentHourCount()
{
    makeRequest("ShipArrivals/GetCurrentHourShipArrival", {}, [this](const QByteArray &data) {
        bool ok;
        int count = data.toInt(&ok);
        if (ok) {
            if (m_currentHourCount != count) { m_currentHourCount = count; emit currentHourCountChanged(); }
            m_lastError.clear();
        } else {
            setError("Invalid response format");
        }
    });
}

void TruckArrivalController::fetchDateRangeCount(const QDate &start, const QDate &end)
{
    QUrlQuery query;
    query.addQueryItem("startDate", start.toString(Qt::ISODate));
    query.addQueryItem("endDate",   end.toString(Qt::ISODate));

    makeRequest("ShipArrivals/GetDateSpanShipArrivals", query, [this](const QByteArray &data) {
        bool ok;
        int count = data.toInt(&ok);
        if (ok) {
            if (m_dateRangeCount != count) { m_dateRangeCount = count; emit dateRangeCountChanged(); }
            m_lastError.clear();
        } else {
            setError("Invalid response format");
        }
    });
}


void TruckArrivalController::fetchDateTimeRangeCount(const QDateTime &start, const QDateTime &end)
{
    QUrlQuery query;
    query.addQueryItem("startDateTime", start.toString(Qt::ISODate));
    query.addQueryItem("endDateTime",   end.toString(Qt::ISODate));

    makeRequest("ShipArrivals/GetDateTimeSpanShipArrivals", query, [this](const QByteArray &data) {
        bool ok;
        int count = data.toInt(&ok);
        if (ok) {
            if (m_dateTimeRangeCount != count) { m_dateTimeRangeCount = count; emit dateTimeRangeCountChanged(); }
            m_lastError.clear();
        } else {
            setError("Invalid response format");
        }
    });
}

void TruckArrivalController::fetchAllBasicData()
{
    // Allow concurrent requests (more responsive)
    fetchTodayCount();
    fetchCurrentHourCount();
}

void TruckArrivalController::makeRequest(const QString &endpoint,
                                         const QUrlQuery &query,
                                         std::function<void(const QByteArray&)> onSuccess)
{
    // Clear any stale error at request start
    if (!m_lastError.isEmpty()) { m_lastError.clear(); emit errorOccurred(QString()); }

    QUrl url = m_baseUrl;
    // --- safer path join ---
    QString basePath = url.path();
    if (!basePath.endsWith('/')) basePath += '/';
    url.setPath(basePath + endpoint);
    // -----------------------

    if (!query.isEmpty()) url.setQuery(query);

    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    incrementRequests();
    QNetworkReply *reply = m_network->get(request);

    connect(reply, &QNetworkReply::finished, this, [this, reply, onSuccess]() {
        decrementRequests();

        if (reply->error() != QNetworkReply::NoError) {
            setError(reply->errorString());
        } else {
            onSuccess(reply->readAll());
        }

        reply->deleteLater();
    });
}

void TruckArrivalController::incrementRequests()
{
    if (m_activeRequests++ == 0) emit isLoadingChanged();
}

void TruckArrivalController::decrementRequests()
{
    if (--m_activeRequests == 0) emit isLoadingChanged();
}

void TruckArrivalController::setError(const QString &error)
{
    m_lastError = error;
    emit errorOccurred(error);
}
