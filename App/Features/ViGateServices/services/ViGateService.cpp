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

void ViGateService::getActiveGates()
{
    qDebug() << "ViGateService::getActiveGates called";

    auto url = makeUrl(m_host, m_port, QStringLiteral("/vigate/GetActiveGates"));
    qDebug() << "ViGateService: Built URL:" << url.toString();

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
            qDebug() << "ViGateService: Active gates not found (404)";
            emit notFound();
            return;
        }
        if (status < 200 || status >= 300) {
            QString error = QStringLiteral("HTTP %1").arg(status);
            qWarning() << "ViGateService: HTTP error:" << error;
            emit requestFailed(error);
            return;
        }

        QByteArray responseData = reply->readAll();
        qDebug() << "ViGateService: Received" << responseData.size() << "bytes";

        QJsonParseError parseError;
        QJsonDocument doc = QJsonDocument::fromJson(responseData, &parseError);

        if (parseError.error != QJsonParseError::NoError) {
            QString error = QStringLiteral("JSON parse error: %1").arg(parseError.errorString());
            qWarning() << "ViGateService:" << error;
            emit requestFailed(error);
            return;
        }

        if (!doc.isArray()) {
            qWarning() << "ViGateService: Expected array response for active gates";
            emit requestFailed(QStringLiteral("Invalid response format"));
            return;
        }

        QJsonArray gates = doc.array();
        qDebug() << "ViGateService: Successfully loaded" << gates.size() << "active gates";

        emit activeGatesReady(gates);
    });
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

        QJsonObject rootObj = doc.object();

        // Expected format: { "data": [...], "pagination": {...}, "summary": {...} }
        if (!rootObj.contains("data") || !rootObj.contains("pagination") || !rootObj.contains("summary")) {
            qWarning() << "ViGateService: Invalid response format - missing data, pagination, or summary";
            emit requestFailed(QStringLiteral("Invalid response format"));
            return;
        }

        qDebug() << "ViGateService: Detected backend response with summary";

        QJsonArray dataArray = rootObj["data"].toArray();
        qDebug() << "ViGateService: Processing" << dataArray.size() << "transit items";

        // Transform transit data
        QJsonArray transformedTransits = transformTransitData(dataArray);

        // Use the provided summary from backend
        QJsonObject providedSummary = rootObj["summary"].toObject();
        QJsonObject convertedSummary;

        convertedSummary["total_entries"] = providedSummary.value("totalEntries").toInt();
        convertedSummary["total_exits"] = providedSummary.value("totalExits").toInt();
        convertedSummary["total_vehicle_entries"] = providedSummary.value("totalVehiclesEntries").toInt();
        convertedSummary["total_vehicle_exits"] = providedSummary.value("totalVehiclesExits").toInt();
        convertedSummary["total_pedestrian_entries"] = providedSummary.value("totalPedestriansEntries").toInt();
        convertedSummary["total_pedestrian_exits"] = providedSummary.value("totalPedestriansExits").toInt();

        qDebug() << "ViGateService: Using backend summary:";
        qDebug() << "  - Entries:" << convertedSummary["total_entries"].toInt()
                 << "(Vehicles:" << convertedSummary["total_vehicle_entries"].toInt()
                 << ", Pedestrians:" << convertedSummary["total_pedestrian_entries"].toInt() << ")";
        qDebug() << "  - Exits:" << convertedSummary["total_exits"].toInt()
                 << "(Vehicles:" << convertedSummary["total_vehicle_exits"].toInt()
                 << ", Pedestrians:" << convertedSummary["total_pedestrian_exits"].toInt() << ")";

        // Build response
        QJsonObject response;
        response["summary"] = convertedSummary;
        response["transits"] = transformedTransits;

        // Extract pagination info
        QJsonObject pagination = rootObj["pagination"].toObject();
        int currentPage = pagination["page"].toInt();
        int totalPages = pagination["totalPages"].toInt();
        int totalItems = pagination["totalItems"].toInt();

        qDebug() << "ViGateService: Pagination - page" << currentPage
                 << "of" << totalPages << "(" << totalItems << "total items)";

        emit paginationInfo(currentPage, totalPages, totalItems);
        emit dataReady(response);
    });
}

QJsonArray ViGateService::transformTransitData(const QJsonArray& transits)
{
    qDebug() << "ViGateService::transformTransitData - Processing" << transits.size() << "transits";

    QJsonArray transformedTransits;

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

        QString laneType = transit["lanetype_id"].toString();

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

        // Permission (first element only) - ALL FIELDS - ONLY FOR VEHICLE
        if (laneType == "VEHICLE" &&
            transit.contains("transit_permissions") &&
            transit["transit_permissions"].isArray()) {
            QJsonArray permissionsArray = transit["transit_permissions"].toArray();
            if (!permissionsArray.isEmpty()) {
                QJsonObject firstPerm = permissionsArray[0].toObject();
                QJsonObject transformedPerm;

                // Map all permission fields
                transformedPerm["uidCode"] = firstPerm["uid_code"].toString();
                transformedPerm["auth"] = firstPerm["auth"].toString();
                transformedPerm["authCode"] = firstPerm["auth_code"].toString();
                transformedPerm["authMessage"] = firstPerm["auth_message"].toString();
                transformedPerm["permissionId"] = firstPerm["permission_id"].toInt();
                transformedPerm["permissionType"] = firstPerm["permissiontype_name"].toString();
                transformedPerm["ownerType"] = firstPerm["ownertype_id"].toString();
                transformedPerm["vehicleId"] = firstPerm["vehicle_id"].toInt();
                transformedPerm["vehiclePlate"] = firstPerm["vehicle_plate"].toString();
                transformedPerm["peopleId"] = firstPerm["people_id"].toInt();
                transformedPerm["peopleFullname"] = firstPerm["people_fullname"].toString();
                transformedPerm["peopleBirthdayDate"] = firstPerm["people_birthday_date"].toString();
                transformedPerm["peopleBirthdayPlace"] = firstPerm["people_birthday_place"].toString();
                transformedPerm["companyId"] = firstPerm["company_id"].toInt();
                transformedPerm["companyFullname"] = firstPerm["company_fullname"].toString();
                transformedPerm["companyCity"] = firstPerm["company_city"].toString();
                transformedPerm["companyType"] = firstPerm["companytype_name"].toString();

                transformed["permission"] = transformedPerm;
            }
        }

        transformedTransits.append(transformed);
    }

    qDebug() << "ViGateService::transformTransitData - Transformed" << transformedTransits.size() << "transits";

    return transformedTransits;
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
