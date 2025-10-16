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

    static const QSet<int> VALID_GATE_IDS = {1, 2, 3, 4, 5};
    if (!VALID_GATE_IDS.contains(gateId)) {
        QTimer::singleShot(100, this, [this]() {
            emit notFound();
        });
        return;
    }

    // MOCK DATA FOR TESTING
    QJsonObject mockResponse;

    // Summary
    // QJsonObject summary;
    // summary["total_entries"] = 150;
    // summary["total_exits"] = 142;
    // summary["total_vehicle_entries"] = 100;
    // summary["total_vehicle_exits"] = 98;
    // summary["total_pedestrian_entries"] = 50;
    // summary["total_pedestrian_exits"] = 44;
    // mockResponse["summary"] = summary;

    // Vehicles
    QJsonArray vehicles;
    if (includeVehicles) {
        // Gate 1 vehicles
        QJsonObject v1;
        v1["idGate"] = 1;
        v1["startDate"] = "2025-09-06T00:29:00Z";
        v1["plate"] = QJsonArray{"EF162WW"};
        v1["direction"] = "IN";
        vehicles.append(v1);

        QJsonObject v2;
        v2["idGate"] = 1;
        v2["startDate"] = "2025-09-06T01:15:00Z";
        v2["plate"] = QJsonArray{"AB123CD"};
        v2["direction"] = "OUT";
        vehicles.append(v2);

        // Gate 2 vehicles
        QJsonObject v3;
        v3["idGate"] = 2;
        v3["startDate"] = "2025-09-06T02:30:00Z";
        v3["plate"] = QJsonArray{"XY999ZZ"};
        v3["direction"] = "IN";
        vehicles.append(v3);

        // Gate 3 vehicles
        QJsonObject v4;
        v4["idGate"] = 3;
        v4["startDate"] = "2025-09-06T03:45:00Z";
        v4["plate"] = QJsonArray{"LM456OP"};
        v4["direction"] = "OUT";
        vehicles.append(v4);
    }

    // Pedestrians
    QJsonArray pedestrians;
    if (includePedestrians) {
        // Gate 1 pedestrians
        QJsonObject p1;
        p1["idGate"] = 1;
        p1["startDate"] = "2025-09-01T07:03:00Z";
        p1["direction"] = "IN";
        pedestrians.append(p1);

        QJsonObject p2;
        p2["idGate"] = 1;
        p2["startDate"] = "2025-09-01T08:22:00Z";
        p2["direction"] = "OUT";
        pedestrians.append(p2);

        // Gate 2 pedestrians
        QJsonObject p3;
        p3["idGate"] = 2;
        p3["startDate"] = "2025-09-01T09:15:00Z";
        p3["direction"] = "IN";
        pedestrians.append(p3);

        // Gate 3 pedestrians
        QJsonObject p4;
        p4["idGate"] = 3;
        p4["startDate"] = "2025-09-01T10:30:00Z";
        p4["direction"] = "OUT";
        pedestrians.append(p4);
    }

    QJsonArray filteredVehicles;
    for (const auto& v : vehicles) {
        QJsonObject obj = v.toObject();
        QDateTime entryDate = QDateTime::fromString(obj["startDate"].toString(), Qt::ISODate);
        if (obj["idGate"].toInt() == gateId && entryDate >= startDate && entryDate <= endDate) {
            filteredVehicles.append(v);
        }
    }

    QJsonArray filteredPedestrians;
    for (const auto& p : pedestrians) {
        QJsonObject obj = p.toObject();
        QDateTime entryDate = QDateTime::fromString(obj["startDate"].toString(), Qt::ISODate);
        if (obj["idGate"].toInt() == gateId  && entryDate >= startDate && entryDate <= endDate) {
            filteredPedestrians.append(p);
        }
    }

    int vehicleEntries = 0, vehicleExits = 0;
    for (const auto& v : filteredVehicles) {
        QJsonObject obj = v.toObject();
        if (obj["direction"].toString() == "IN") vehicleEntries++;
        else vehicleExits++;
    }

    int pedestrianEntries = 0, pedestrianExits = 0;
    for (const auto& p : filteredPedestrians) {
        QJsonObject obj = p.toObject();
        if (obj["direction"].toString() == "IN") pedestrianEntries++;
        else pedestrianExits++;
    }

    QJsonObject summary;
    summary["total_vehicle_entries"] = vehicleEntries;
    summary["total_vehicle_exits"] = vehicleExits;
    summary["total_pedestrian_entries"] = pedestrianEntries;
    summary["total_pedestrian_exits"] = pedestrianExits;
    summary["total_entries"] = vehicleEntries + pedestrianEntries;
    summary["total_exits"] = vehicleExits + pedestrianExits;

    mockResponse["summary"] = summary;
    mockResponse["vehicles"] = filteredVehicles;
    mockResponse["pedestrian"] = filteredPedestrians;

    // Simulate network delay
    QTimer::singleShot(1000, this, [this, mockResponse]() {
        emit dataReady(mockResponse);
    });
}
