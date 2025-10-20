#include "ViGateService.h"
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QUrlQuery>
#include <QJsonDocument>
#include <QJsonObject>
#include <QScopeGuard>
#include <QJsonArray>
#include <QDebug>

// #define USE_MOCK_DATA

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

#ifdef USE_MOCK_DATA
    qDebug() << "ViGateService: Using MOCK DATA";
    useMockData(gateId, startDate, endDate, includeVehicles, includePedestrians);
#else
    qDebug() << "ViGateService: Making real API call";
    auto url = makeUrl(m_host, m_port, QStringLiteral("/ViGate/GetGateData"),
                       [&](QUrlQuery& q) {
                           q.addQueryItem(QStringLiteral("gateId"), QString::number(gateId));
                           q.addQueryItem(QStringLiteral("startDate"), startDate.toString(Qt::ISODate));
                           q.addQueryItem(QStringLiteral("endDate"), endDate.toString(Qt::ISODate));
                           q.addQueryItem(QStringLiteral("includeVehicles"), includeVehicles ? "true" : "false");
                           q.addQueryItem(QStringLiteral("includePedestrians"), includePedestrians ? "true" : "false");
                       });
    performGet(url);
#endif
}

#ifdef USE_MOCK_DATA
void ViGateService::useMockData(int gateId,
                                const QDateTime& startDate,
                                const QDateTime& endDate,
                                bool includeVehicles,
                                bool includePedestrians)
{
    // Validate gate ID
    static const QSet<int> VALID_GATE_IDS = {12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 26};
    if (!VALID_GATE_IDS.contains(gateId)) {
        QTimer::singleShot(100, this, [this]() {
            qDebug() << "Mock: Gate not found";
            emit notFound();
        });
        return;
    }

    QJsonObject mockResponse;

    // Vehicles
    QJsonArray vehicles;
    if (includeVehicles) {
        QJsonObject v1;
        v1["idGate"] = gateId;
        v1["startDate"] = "2025-09-01T08:00:00Z";
        v1["plate"] = QJsonArray{"EF162WW"};
        v1["direction"] = "IN";
        v1["idPeople"] = 3986;
        v1["idTitle"] = 4916;
        vehicles.append(v1);

        QJsonObject v2;
        v2["idGate"] = gateId;
        v2["startDate"] = "2025-09-01T09:15:00Z";
        v2["plate"] = QJsonArray{"AB123CD"};
        v2["direction"] = "OUT";
        v2["idPeople"] = 1234;
        v2["idTitle"] = 5678;
        vehicles.append(v2);
    }

    // Pedestrians
    QJsonArray pedestrians;
    if (includePedestrians) {
        QJsonObject p1;
        p1["idGate"] = gateId;
        p1["startDate"] = "2025-09-01T07:03:00Z";
        p1["direction"] = "IN";
        p1["idPeople"] = 87;
        p1["idTitle"] = 1043;
        pedestrians.append(p1);

        QJsonObject p2;
        p2["idGate"] = gateId;
        p2["startDate"] = "2025-09-01T08:22:00Z";
        p2["direction"] = "OUT";
        p2["idPeople"] = 431;
        p2["idTitle"] = 1187;
        pedestrians.append(p2);
    }

    // Filter by date
    QJsonArray filteredVehicles;
    for (const auto& v : vehicles) {
        QJsonObject obj = v.toObject();
        QDateTime entryDate = QDateTime::fromString(obj["startDate"].toString(), Qt::ISODate);
        if (entryDate >= startDate && entryDate <= endDate) {
            filteredVehicles.append(v);
        }
    }

    QJsonArray filteredPedestrians;
    for (const auto& p : pedestrians) {
        QJsonObject obj = p.toObject();
        QDateTime entryDate = QDateTime::fromString(obj["startDate"].toString(), Qt::ISODate);
        if (entryDate >= startDate && entryDate <= endDate) {
            filteredPedestrians.append(p);
        }
    }

    // Calculate summary
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
    QTimer::singleShot(500, this, [this, mockResponse]() {
        qDebug() << "Mock: Emitting data";
        emit dataReady(mockResponse);
    });
}
#endif
