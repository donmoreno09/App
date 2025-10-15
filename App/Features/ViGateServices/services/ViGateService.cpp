#include "ViGateService.h"
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QUrlQuery>
#include <QJsonDocument>
#include <QJsonObject>
#include <QScopeGuard>
#include <QJsonArray>
#include <QTimer>

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
    QNetworkRequest req(url);
    req.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    QNetworkReply* reply = m_manager.get(req);
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        const auto finish = qScopeGuard([&]{ reply->deleteLater(); });

        if (reply->error() != QNetworkReply::NoError) {
            emit requestFailed(reply->errorString());
            return;
        }

        const int status = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
        if (status == 404) {
            emit notFound();
            return;
        }
        if (status < 200 || status >= 300) {
            emit requestFailed(QStringLiteral("HTTP %1").arg(status));
            return;
        }

        // Parse JSON response
        QJsonParseError parseError;
        QJsonDocument doc = QJsonDocument::fromJson(reply->readAll(), &parseError);

        if (parseError.error != QJsonParseError::NoError) {
            emit requestFailed(QStringLiteral("JSON parse error: %1").arg(parseError.errorString()));
            return;
        }

        if (!doc.isObject()) {
            emit requestFailed(QStringLiteral("Invalid response format"));
            return;
        }

        emit dataReady(doc.object());
    });
}

// void ViGateService::getGateData(int gateId,
//                                 const QDateTime& startDate,
//                                 const QDateTime& endDate,
//                                 bool includeVehicles,
//                                 bool includePedestrians)
// {
//     auto url = makeUrl(m_host, m_port, QStringLiteral("/ViGate/GetGateData"),
//                        [&](QUrlQuery& q) {
//                            q.addQueryItem(QStringLiteral("gateId"), QString::number(gateId));
//                            q.addQueryItem(QStringLiteral("startDate"), startDate.toString(Qt::ISODate));
//                            q.addQueryItem(QStringLiteral("endDate"), endDate.toString(Qt::ISODate));
//                            q.addQueryItem(QStringLiteral("includeVehicles"), includeVehicles ? "true" : "false");
//                            q.addQueryItem(QStringLiteral("includePedestrians"), includePedestrians ? "true" : "false");
//                        });
//     performGet(url);
// }

void ViGateService::getGateData(int gateId,
                                const QDateTime& startDate,
                                const QDateTime& endDate,
                                bool includeVehicles,
                                bool includePedestrians)
{
    // MOCK DATA FOR TESTING
    QJsonObject mockResponse;

    // Summary
    QJsonObject summary;
    summary["total_entries"] = 150;
    summary["total_exits"] = 142;
    summary["total_vehicle_entries"] = 100;
    summary["total_vehicle_exits"] = 98;
    summary["total_pedestrian_entries"] = 50;
    summary["total_pedestrian_exits"] = 44;
    mockResponse["summary"] = summary;

    // Vehicles
    QJsonArray vehicles;
    if (includeVehicles) {
        QJsonObject v1;
        v1["idGate"] = gateId;
        v1["startDate"] = "2025-09-06T00:29:00Z";
        v1["plate"] = QJsonArray{"EF162WW"};
        v1["direction"] = "IN";
        vehicles.append(v1);

        QJsonObject v2;
        v2["idGate"] = gateId;
        v2["startDate"] = "2025-09-06T01:15:00Z";
        v2["plate"] = QJsonArray{"AB123CD"};
        v2["direction"] = "OUT";
        vehicles.append(v2);
    }
    mockResponse["vehicles"] = vehicles;

    // Pedestrians
    QJsonArray pedestrians;
    if (includePedestrians) {
        QJsonObject p1;
        p1["idGate"] = gateId;
        p1["startDate"] = "2025-09-01T07:03:00Z";
        p1["direction"] = "IN";
        pedestrians.append(p1);

        QJsonObject p2;
        p2["idGate"] = gateId;
        p2["startDate"] = "2025-09-01T08:22:00Z";
        p2["direction"] = "OUT";
        pedestrians.append(p2);
    }
    mockResponse["pedestrian"] = pedestrians;

    // Simulate network delay
    QTimer::singleShot(1000, this, [this, mockResponse]() {
        emit dataReady(mockResponse);
    });
}
