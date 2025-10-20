#include "ViGateService.h"
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QUrlQuery>
#include <QJsonDocument>
#include <QJsonObject>
#include <QScopeGuard>
#include <QJsonArray>
#include <QDebug>

ViGateService::ViGateService(QObject* parent)
    : QObject(parent)
{}

void ViGateService::setHostPort(const QString& host, int port)
{
    m_host = host;
    m_port = port;
}

QUrl ViGateService::makeUrl(const QString& host, int port,
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

void ViGateService::performGet(const QUrl& url)
{
    qDebug() << "ViGateService: Fetching" << url.toString();

    QNetworkRequest req(url);
    req.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    QNetworkReply* reply = m_manager.get(req);
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        const auto finish = qScopeGuard([&]{ reply->deleteLater(); });

        if (reply->error() != QNetworkReply::NoError) {
            qWarning() << "ViGateService: Network error:" << reply->errorString();
            emit requestFailed(reply->errorString());
            return;
        }

        const int status = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
        qDebug() << "ViGateService: HTTP status" << status;

        if (status == 404) {
            qDebug() << "ViGateService: Data not found (404)";
            emit notFound();
            return;
        }
        if (status < 200 || status >= 300) {
            QString error = QStringLiteral("HTTP %1").arg(status);
            qWarning() << "ViGateService: HTTP error:" << error;
            emit requestFailed(error);
            return;
        }

        // Parse JSON response
        QByteArray responseData = reply->readAll();
        QJsonParseError parseError;
        QJsonDocument doc = QJsonDocument::fromJson(responseData, &parseError);

        if (parseError.error != QJsonParseError::NoError) {
            QString error = QStringLiteral("JSON parse error: %1").arg(parseError.errorString());
            qWarning() << "ViGateService:" << error;
            qWarning() << "Response data:" << responseData;
            emit requestFailed(error);
            return;
        }

        if (!doc.isObject()) {
            qWarning() << "ViGateService: Invalid response format (not an object)";
            emit requestFailed(QStringLiteral("Invalid response format"));
            return;
        }

        QJsonObject response = doc.object();
        qDebug() << "ViGateService: Successfully parsed response";

        // Log what we received
        if (response.contains("summary")) {
            QJsonObject summary = response["summary"].toObject();
            qDebug() << "  - Total entries:" << summary["total_entries"].toInt();
        }
        if (response.contains("vehicles")) {
            int vCount = response["vehicles"].toArray().size();
            qDebug() << "  - Vehicles:" << vCount;
        }
        if (response.contains("pedestrian")) {
            int pCount = response["pedestrian"].toArray().size();
            qDebug() << "  - Pedestrians:" << pCount;
        }

        emit dataReady(response);
    });
}

void ViGateService::getGateData(int gateId,
                                const QDateTime& startDate,
                                const QDateTime& endDate,
                                bool includeVehicles,
                                bool includePedestrians)
{
    qDebug() << "ViGateService::getGateData called";
    qDebug() << "  - Gate ID:" << gateId;
    qDebug() << "  - Date range:" << startDate.toString(Qt::ISODate)
             << "to" << endDate.toString(Qt::ISODate);
    qDebug() << "  - Include vehicles:" << includeVehicles;
    qDebug() << "  - Include pedestrians:" << includePedestrians;

    auto url = makeUrl(m_host, m_port, QStringLiteral("/ViGate/GetGateData"),
                       [&](QUrlQuery& q) {
                           q.addQueryItem(QStringLiteral("gateId"), QString::number(gateId));
                           q.addQueryItem(QStringLiteral("startDate"), startDate.toString(Qt::ISODate));
                           q.addQueryItem(QStringLiteral("endDate"), endDate.toString(Qt::ISODate));
                           q.addQueryItem(QStringLiteral("includeVehicles"), includeVehicles ? "true" : "false");
                           q.addQueryItem(QStringLiteral("includePedestrians"), includePedestrians ? "true" : "false");
                       });
    performGet(url);
}

