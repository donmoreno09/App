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
    qDebug() << "ViGateService: Host set to" << m_host << ":" << m_port;
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
    qDebug() << "ViGateService::performGet - Fetching" << url.toString();

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
        qDebug() << "ViGateService: Received" << responseData.size() << "bytes";

        QJsonParseError parseError;
        QJsonDocument doc = QJsonDocument::fromJson(responseData, &parseError);

        if (parseError.error != QJsonParseError::NoError) {
            QString error = QStringLiteral("JSON parse error: %1").arg(parseError.errorString());
            qWarning() << "ViGateService:" << error;
            qWarning() << "Response data (first 500 chars):" << responseData.left(500);
            emit requestFailed(error);
            return;
        }

        QJsonObject response;
        QJsonObject rootObj = doc.object();

        // Check if response has pagination wrapper
        if (rootObj.contains("data") && rootObj.contains("pagination")) {
            qDebug() << "ViGateService: Detected paginated response";

            // Backend sent paginated response
            QJsonArray dataArray = rootObj["data"].toArray();
            qDebug() << "ViGateService: Processing" << dataArray.size() << "transit items";

            response = transformTransitData(dataArray);

            // Extract pagination info
            QJsonObject pagination = rootObj["pagination"].toObject();
            int currentPage = pagination["page"].toInt();
            int totalPages = pagination["totalPages"].toInt();
            int totalItems = pagination["totalItems"].toInt();

            qDebug() << "ViGateService: Pagination - page" << currentPage
                     << "of" << totalPages << "(" << totalItems << "total items)";

            emit paginationInfo(currentPage, totalPages, totalItems);

        } else if (doc.isArray()) {
            qDebug() << "ViGateService: Detected array response (no pagination wrapper)";

            // Backend sent array without pagination
            QJsonArray dataArray = doc.array();
            qDebug() << "ViGateService: Processing" << dataArray.size() << "transit items";

            response = transformTransitData(dataArray);

        } else if (doc.isObject()) {
            qDebug() << "ViGateService: Detected pre-formatted object response";

            // Backend sent pre-formatted response
            response = doc.object();

        } else {
            qWarning() << "ViGateService: Invalid response format";
            emit requestFailed(QStringLiteral("Invalid response format"));
            return;
        }

        qDebug() << "ViGateService: Successfully processed response";

        // Log what we're emitting
        if (response.contains("summary")) {
            QJsonObject summary = response["summary"].toObject();
            qDebug() << "  - Summary: total_entries =" << summary["total_entries"].toInt();
        }
        if (response.contains("transits")) {
            int transitCount = response["transits"].toArray().size();
            qDebug() << "  - Transits:" << transitCount << "items";
        }

        emit dataReady(response);
    });
}

QJsonObject ViGateService::transformTransitData(const QJsonArray& transits)
{
    qDebug() << "ViGateService::transformTransitData - Processing" << transits.size() << "transits";

    QJsonObject result;
    QJsonArray transformedTransits;

    int totalEntries = 0;
    int totalExits = 0;
    int totalVehicleEntries = 0;
    int totalVehicleExits = 0;
    int totalPedestrianEntries = 0;
    int totalPedestrianExits = 0;

    for (int i = 0; i < transits.size(); ++i) {
        const auto& value = transits[i];

        if (!value.isObject()) {
            qWarning() << "ViGateService: Skipping non-object at index" << i;
            continue;
        }

        QJsonObject transitObj = value.toObject();

        // Check if this is an EndTransit object with nested "transit"
        if (!transitObj.contains("transit") || !transitObj["transit"].isObject()) {
            qWarning() << "ViGateService: Missing 'transit' object at index" << i;
            continue;
        }

        QJsonObject transit = transitObj["transit"].toObject();

        QJsonObject transformed;

        // Basic info from root level
        transformed["transitId"] = transitObj["transit_id"].toString();
        transformed["gateName"] = transitObj["gate_name"].toString();
        transformed["transitStartDate"] = transitObj["transit_start_date"].toString();
        transformed["transitEndDate"] = transitObj["transit_end_date"].toString();
        transformed["transitStatus"] = transitObj["transit_status"].toString();

        // Lane info from transit object
        transformed["laneTypeId"] = transit["lanetype_id"].toString();
        transformed["laneStatusId"] = transit["lanestatus_id"].toString();
        transformed["laneName"] = transit["lane_name"].toString();
        transformed["transitDirection"] = transit["transitdirection_id"].toString();

        QString direction = transit["transitdirection_id"].toString();
        QString laneType = transit["lanetype_id"].toString();

        // Count totals
        if (direction == "IN") {
            totalEntries++;
        } else if (direction == "OUT") {
            totalExits++;
        }

        // Transit Info (only for VEHICLE)
        if (transit.contains("transit_info") && transit["transit_info"].isObject()) {
            QJsonObject infoObj = transit["transit_info"].toObject();
            QJsonObject transformedInfo;

            transformedInfo["color"] = infoObj["color"].toString();
            transformedInfo["macroClass"] = infoObj["macro_class"].toString();
            transformedInfo["microClass"] = infoObj["micro_class"].toString();
            transformedInfo["make"] = infoObj["make"].toString();
            transformedInfo["model"] = infoObj["model"].toString();
            transformedInfo["country"] = infoObj["country"].toString();
            transformedInfo["kemler"] = infoObj["kemler"].toString();

            transformed["transitInfo"] = transformedInfo;
        }

        // Permission (first element only)
        if (transit.contains("transit_permissions") && transit["transit_permissions"].isArray()) {
            QJsonArray permissionsArray = transit["transit_permissions"].toArray();
            if (!permissionsArray.isEmpty()) {
                QJsonObject firstPerm = permissionsArray[0].toObject();
                QJsonObject transformedPerm;

                transformedPerm["uidCode"] = firstPerm["uid_code"].toString();
                transformedPerm["auth"] = firstPerm["auth"].toString();
                transformedPerm["authMessage"] = firstPerm["auth_message"].toString();
                transformedPerm["permissionType"] = firstPerm["permissiontype_name"].toString();
                transformedPerm["vehiclePlate"] = firstPerm["vehicle_plate"].toString();
                transformedPerm["peopleFullname"] = firstPerm["people_fullname"].toString();
                transformedPerm["companyFullname"] = firstPerm["company_fullname"].toString();

                transformed["permission"] = transformedPerm;
            }
        }

        // Count by type
        if (laneType == "VEHICLE") {
            if (direction == "IN") {
                totalVehicleEntries++;
            } else if (direction == "OUT") {
                totalVehicleExits++;
            }
        } else if (laneType == "WALK") {
            if (direction == "IN") {
                totalPedestrianEntries++;
            } else if (direction == "OUT") {
                totalPedestrianExits++;
            }
        }

        transformedTransits.append(transformed);
    }

    qDebug() << "ViGateService::transformTransitData - Transformed" << transformedTransits.size() << "transits";
    qDebug() << "  - Vehicle entries:" << totalVehicleEntries << ", exits:" << totalVehicleExits;
    qDebug() << "  - Pedestrian entries:" << totalPedestrianEntries << ", exits:" << totalPedestrianExits;

    // Build summary
    QJsonObject summary;
    summary["total_entries"] = totalEntries;
    summary["total_exits"] = totalExits;
    summary["total_vehicle_entries"] = totalVehicleEntries;
    summary["total_vehicle_exits"] = totalVehicleExits;
    summary["total_pedestrian_entries"] = totalPedestrianEntries;
    summary["total_pedestrian_exits"] = totalPedestrianExits;

    result["summary"] = summary;
    result["transits"] = transformedTransits;

    return result;
}

void ViGateService::getGateData(int gateId,
                                const QDateTime& startDate,
                                const QDateTime& endDate,
                                bool includeVehicles,
                                bool includePedestrians,
                                int page,
                                int pageSize)
{
    qDebug() << "ViGateService::getGateData called";
    qDebug() << "  - Gate ID:" << gateId;
    qDebug() << "  - Date range:" << startDate.toString(Qt::ISODate)
             << "to" << endDate.toString(Qt::ISODate);
    qDebug() << "  - Include vehicles:" << includeVehicles;
    qDebug() << "  - Include pedestrians:" << includePedestrians;
    qDebug() << "  - Page:" << page << ", Page size:" << pageSize;

    auto url = makeUrl(m_host, m_port, QStringLiteral("/ViGate/GetGateData"),
                       [&](QUrlQuery& q) {
                           q.addQueryItem(QStringLiteral("gateId"), QString::number(gateId));
                           q.addQueryItem(QStringLiteral("startDate"), startDate.toString(Qt::ISODate));
                           q.addQueryItem(QStringLiteral("endDate"), endDate.toString(Qt::ISODate));
                           q.addQueryItem(QStringLiteral("includeVehicles"), includeVehicles ? "true" : "false");
                           q.addQueryItem(QStringLiteral("includePedestrians"), includePedestrians ? "true" : "false");
                           q.addQueryItem(QStringLiteral("page"), QString::number(page));
                           q.addQueryItem(QStringLiteral("pageSize"), QString::number(pageSize));
                       });

    qDebug() << "ViGateService: Built URL:" << url.toString();
    performGet(url);
}
