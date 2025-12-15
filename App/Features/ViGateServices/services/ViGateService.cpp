#include "ViGateService.h"
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QUrlQuery>
#include <QJsonDocument>
#include <QJsonObject>
#include <QScopeGuard>
#include <QJsonArray>
#include <QDebug>
#include <QtConcurrent>

ViGateService::ViGateService(QObject* parent)
    : QObject(parent)
    , m_parseWatcher(new QFutureWatcher<QJsonObject>(this))
{
    connect(m_parseWatcher, &QFutureWatcher<QJsonObject>::finished, this, &ViGateService::onParseFinished);
}

ViGateService::~ViGateService()
{
    // Cancel any ongoing background work
    if (m_parseWatcher->isRunning()) {
        m_parseWatcher->cancel();
        m_parseWatcher->waitForFinished();
    }
}

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

        // Get response data and move to background thread for parsing
        QByteArray responseData = reply->readAll();
        qDebug() << "ViGateService: Received" << responseData.size() << "bytes - starting background parse";

        // Cancel any previous parse operation
        if (m_parseWatcher->isRunning()) {
            qDebug() << "ViGateService: Cancelling previous parse operation";
            m_parseWatcher->cancel();
            m_parseWatcher->waitForFinished();
        }

        QJsonParseError parseError;
        QJsonDocument doc = QJsonDocument::fromJson(responseData, &parseError);
        QJsonObject rootObj = doc.object();

        qDebug() << "=== BACKEND RESPONSE ANALYSIS ===";
        qDebug() << "Backend says pageNumber:" << rootObj["pageNumber"].toInt();
        qDebug() << "Backend says pageSize:" << rootObj["pageSize"].toInt();
        qDebug() << "Backend says totalCount:" << rootObj["totalCount"].toInt();
        qDebug() << "Backend says totalPages:" << rootObj["totalPages"].toInt();
        qDebug() << "Backend ACTUALLY returned items.length:" << rootObj["items"].toArray().size();
        qDebug() << "=== EXPECTED vs ACTUAL ===";
        qDebug() << "EXPECTED items on this page:" << rootObj["pageSize"].toInt();
        qDebug() << "ACTUAL items received:" << rootObj["items"].toArray().size();
        qDebug() << "=================================";

        // Start background parsing using QtConcurrent
        QFuture<QJsonObject> future = QtConcurrent::run([responseData]() {
            return ViGateService::parseAndTransformResponse(responseData);
        });

        m_parseWatcher->setFuture(future);
    });
}

void ViGateService::onParseFinished()
{
    if (m_parseWatcher->isCanceled()) {
        qDebug() << "ViGateService: Parse operation was cancelled";
        return;
    }

    QJsonObject result = m_parseWatcher->result();

    // Check if parsing failed
    if (result.contains("error")) {
        QString error = result["error"].toString();
        qWarning() << "ViGateService: Background parse error:" << error;
        emit requestFailed(error);
        return;
    }

    qDebug() << "ViGateService: Background parsing completed successfully";

    // Extract pagination info
    int currentPage = result["currentPage"].toInt();
    int totalPages = result["totalPages"].toInt();
    int totalItems = result["totalCount"].toInt();

    qDebug() << "ViGateService: Pagination - page" << currentPage
             << "of" << totalPages << "(" << totalItems << "total items)";

    // Build final response for controller
    QJsonObject response;
    response["summary"] = result["summary"];
    response["transits"] = result["transits"];

    emit paginationInfo(currentPage, totalPages, totalItems);
    emit dataReady(response);
}

// Static method - runs in background thread
QJsonObject ViGateService::parseAndTransformResponse(const QByteArray& responseData)
{
    QJsonObject result;

    // Parse JSON
    QJsonParseError parseError;
    QJsonDocument doc = QJsonDocument::fromJson(responseData, &parseError);

    if (parseError.error != QJsonParseError::NoError) {
        result["error"] = QStringLiteral("JSON parse error: %1").arg(parseError.errorString());
        return result;
    }

    QJsonObject rootObj = doc.object();

    // Validate structure
    if (!rootObj.contains("items") || !rootObj.contains("pageNumber") || !rootObj.contains("summary")) {
        result["error"] = QStringLiteral("Invalid response format - missing items, pageNumber, or summary");
        return result;
    }

    QJsonArray dataArray = rootObj["items"].toArray();
    qDebug() << "ViGateService: Background thread processing" << dataArray.size() << "transit items";

    // Transform transit data in background
    QJsonArray transformedTransits = transformTransitData(dataArray);

    // Convert summary
    QJsonObject providedSummary = rootObj["summary"].toObject();
    QJsonObject convertedSummary;
    convertedSummary["total_entries"] = providedSummary.value("totalEntries").toInt();
    convertedSummary["total_exits"] = providedSummary.value("totalExits").toInt();
    convertedSummary["total_vehicle_entries"] = providedSummary.value("totalVehiclesEntries").toInt();
    convertedSummary["total_vehicle_exits"] = providedSummary.value("totalVehiclesExits").toInt();
    convertedSummary["total_pedestrian_entries"] = providedSummary.value("totalPedestriansEntries").toInt();
    convertedSummary["total_pedestrian_exits"] = providedSummary.value("totalPedestriansExits").toInt();

    // Pack results
    result["summary"] = convertedSummary;
    result["transits"] = transformedTransits;
    result["currentPage"] = rootObj["pageNumber"].toInt();
    result["totalPages"] = rootObj["totalPages"].toInt();
    result["totalCount"] = rootObj["totalCount"].toInt();

    return result;
}

// Static method - runs in background thread
QJsonArray ViGateService::transformTransitData(const QJsonArray& transits)
{
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

        // Transit Info (ONLY for VEHICLE, not for WALK)
        if (laneType == "VEHICLE" &&
            transit.contains("transit_info") &&
            transit["transit_info"].isObject()) {
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

        // Permission (first element only) - ALL FIELDS - FOR BOTH VEHICLE AND WALK
        if ((laneType == "VEHICLE" || laneType == "WALK") &&
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

    qDebug() << "ViGateService: Background thread transformed" << transformedTransits.size() << "transits";

    return transformedTransits;
}

void ViGateService::getFilteredViGateData(int gateId,
                                          const QDateTime& startDate,
                                          const QDateTime& endDate,
                                          bool pedestrian,
                                          bool vehicle,
                                          int pageNumber,
                                          int pageSize,
                                          const QString& sortBy,
                                          bool sortDescending)
{
    qDebug() << "ViGateService::getFilteredViGateData called";
    qDebug() << "  - Gate ID:" << gateId;
    qDebug() << "  - Date range:" << startDate.toString(Qt::ISODate)
             << "to" << endDate.toString(Qt::ISODate);
    qDebug() << "  - Pedestrian:" << pedestrian;
    qDebug() << "  - Vehicle:" << vehicle;
    qDebug() << "  - Page:" << pageNumber << ", Page size:" << pageSize;
    if (!sortBy.isEmpty()) {
        qDebug() << "  - Sort by:" << sortBy << "(descending:" << sortDescending << ")";
    }

    auto url = makeUrl(m_host, m_port, QStringLiteral("/vigate/GetFilteredViGateData"),
                       [&](QUrlQuery& q) {
                           // Required parameters matching the API spec
                           q.addQueryItem(QStringLiteral("GateId"), QString::number(gateId));
                           q.addQueryItem(QStringLiteral("StartDate"), startDate.toString(Qt::ISODate));
                           q.addQueryItem(QStringLiteral("EndDate"), endDate.toString(Qt::ISODate));
                           q.addQueryItem(QStringLiteral("Pedestrian"), pedestrian ? "true" : "false");
                           q.addQueryItem(QStringLiteral("Vehicle"), vehicle ? "true" : "false");
                           q.addQueryItem(QStringLiteral("PageNumber"), QString::number(pageNumber));
                           q.addQueryItem(QStringLiteral("PageSize"), QString::number(pageSize));

                           // Optional sorting parameters
                           if (!sortBy.isEmpty()) {
                               q.addQueryItem(QStringLiteral("SortBy"), sortBy);
                               q.addQueryItem(QStringLiteral("SortDescending"), sortDescending ? "true" : "false");
                           }
                       });

    qDebug() << "ViGateService: Built URL:" << url.toString();
    performGet(url);
}
