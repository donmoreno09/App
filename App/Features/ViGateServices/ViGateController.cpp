#include "ViGateController.h"
#include "apis/ViGateApi.h"
#include "HttpClient.h"
#include <QDebug>

ViGateController::ViGateController(QObject* parent)
    : QObject(parent)
    , m_transitsModel(new TransitModel(this))
{}

void ViGateController::initialize(HttpClient* http)
{
    m_api = new ViGateApi(http, this);
}

// ── State helpers ─────────────────────────────────────────────────────────────

void ViGateController::setLoading(bool loading)
{
    if (m_loading == loading) return;
    m_loading = loading;
    emit loadingChanged(loading);
}

void ViGateController::setLoadingPage(bool loading)
{
    if (m_loadingPage == loading) return;
    m_loadingPage = loading;
    emit loadingPageChanged(loading);
}

void ViGateController::setLoadingGates(bool loading)
{
    if (m_loadingGates == loading) return;
    m_loadingGates = loading;
    emit loadingGatesChanged(loading);
}

void ViGateController::setPageSize(int size)
{
    if (m_pageSize == size || size < 1) return;
    m_pageSize = size;
    emit pageSizeChanged();
    m_currentPage = 1;
    emit paginationChanged();
    if (m_gateId > 0) fetchCurrentPage();
}

// ── Public slots ──────────────────────────────────────────────────────────────

void ViGateController::loadActiveGates()
{
    qDebug().noquote() << "[ViGate] loadActiveGates() called, m_api =" << (m_api ? "valid" : "NULL");
    if (!m_api) return;

    setLoadingGates(true);

    m_api->getActiveGates(
        [this](const QJsonArray& gates) {
            qDebug().noquote() << "[ViGate] getActiveGates success, count =" << gates.size();
            m_activeGates.clear();
            for (const auto& val : gates) {
                if (!val.isObject()) continue;
                QJsonObject obj = val.toObject();
                QVariantMap gate;
                gate["id"]   = obj["id"].toInt();
                gate["name"] = obj["name"].toString();
                m_activeGates.append(gate);
            }
            emit activeGatesChanged();
            setLoadingGates(false);
        },
        [this](const ErrorResult& err) {
            qWarning().noquote() << "[ViGate] getActiveGates failed: HTTP"
                                 << err.status << err.message;
            emit requestFailed(err.message);
            setLoadingGates(false);
        }
    );
}

void ViGateController::fetchGateData(int gateId,
                                     const QDateTime& startDate,
                                     const QDateTime& endDate,
                                     bool includeVehicles,
                                     bool includePedestrians)
{
    m_gateId             = gateId;
    m_startDate          = startDate;
    m_endDate            = endDate;
    m_includeVehicles    = includeVehicles;
    m_includePedestrians = includePedestrians;
    m_currentPage        = 1;
    fetchCurrentPage();
}

void ViGateController::nextPage()
{
    if (m_currentPage < m_totalPages) {
        ++m_currentPage;
        emit paginationChanged();
        fetchCurrentPage();
    }
}

void ViGateController::previousPage()
{
    if (m_currentPage > 1) {
        --m_currentPage;
        emit paginationChanged();
        fetchCurrentPage();
    }
}

void ViGateController::goToPage(int page)
{
    if (page >= 1 && page <= m_totalPages && page != m_currentPage) {
        m_currentPage = page;
        emit paginationChanged();
        fetchCurrentPage();
    }
}

void ViGateController::clearData()
{
    m_transitsModel->clear();

    m_totalEntries          = 0;
    m_totalExits            = 0;
    m_totalVehicleEntries   = 0;
    m_totalVehicleExits     = 0;
    m_totalPedestrianEntries = 0;
    m_totalPedestrianExits  = 0;
    m_currentPage           = 1;
    m_totalPages            = 0;
    m_totalItems            = 0;
    m_gateId                = 0;

    emit summaryChanged();
    emit paginationChanged();

    if (m_hasData) {
        m_hasData = false;
        emit hasDataChanged(false);
    }
}

// ── Private ───────────────────────────────────────────────────────────────────

void ViGateController::fetchCurrentPage()
{
    qDebug().noquote() << "[ViGate] fetchCurrentPage() — gateId:" << m_gateId
                       << "page:" << m_currentPage << "pageSize:" << m_pageSize
                       << "m_api:" << (m_api ? "valid" : "NULL")
                       << "loading:" << m_loading << "loadingPage:" << m_loadingPage;
    if (!m_api || m_loading || m_loadingPage) return;

    if (m_hasError) {
        m_hasError = false;
        emit hasErrorChanged(false);
    }

    m_hasData ? setLoadingPage(true) : setLoading(true);

    m_api->getFilteredData(
        m_gateId, m_startDate, m_endDate,
        m_includePedestrians, m_includeVehicles,
        m_currentPage, m_pageSize,
        QString{}, false,
        [this](const QJsonObject& obj) {
            qDebug().noquote() << "[ViGate] getFilteredData success — items:" << obj["items"].toArray().size()
                               << "totalPages:" << obj["totalPages"].toInt()
                               << "totalCount:" << obj["totalCount"].toInt();
            processSummary(obj["summary"].toObject());
            m_transitsModel->setData(transformTransitData(obj["items"].toArray()));

            m_currentPage = obj["pageNumber"].toInt();
            m_totalPages  = obj["totalPages"].toInt();
            m_totalItems  = obj["totalCount"].toInt();
            emit paginationChanged();

            if (!m_hasData) { m_hasData = true; emit hasDataChanged(true); }
            if (m_hasError)  { m_hasError = false; emit hasErrorChanged(false); }
            setLoading(false);
            setLoadingPage(false);
        },
        [this](const ErrorResult& err) {
            qWarning().noquote() << "[ViGate] getFilteredData failed: HTTP"
                                 << err.status << err.message;
            emit requestFailed(err.message);
            if (!m_hasError) { m_hasError = true; emit hasErrorChanged(true); }
            if (m_hasData)   { m_hasData = false; emit hasDataChanged(false); }
            setLoading(false);
            setLoadingPage(false);
        }
    );
}

void ViGateController::processSummary(const QJsonObject& summary)
{
    m_totalEntries           = summary["totalEntries"].toInt();
    m_totalExits             = summary["totalExits"].toInt();
    m_totalVehicleEntries    = summary["totalVehiclesEntries"].toInt();
    m_totalVehicleExits      = summary["totalVehiclesExits"].toInt();
    m_totalPedestrianEntries = summary["totalPedestriansEntries"].toInt();
    m_totalPedestrianExits   = summary["totalPedestriansExits"].toInt();
    emit summaryChanged();
}

QJsonArray ViGateController::transformTransitData(const QJsonArray& transits)
{
    QJsonArray result;

    for (int i = 0; i < transits.size(); ++i) {
        if (!transits[i].isObject()) continue;

        QJsonObject transitObj = transits[i].toObject();

        if (!transitObj.contains("transit") || !transitObj["transit"].isObject()) {
            qWarning() << "ViGateController: Missing 'transit' object at index" << i;
            continue;
        }

        QJsonObject transit = transitObj["transit"].toObject();
        QJsonObject out;

        out["transitId"]        = transitObj["transit_id"].toString();
        out["gateName"]         = transitObj["gate_name"].toString();
        out["transitStartDate"] = transitObj["transit_start_date"].toString();
        out["transitEndDate"]   = transitObj["transit_end_date"].toString();
        out["transitStatus"]    = transitObj["transit_status"].toString();

        out["laneTypeId"]         = transit["lanetype_id"].toString();
        out["laneStatusId"]       = transit["lanestatus_id"].toString();
        out["laneName"]           = transit["lane_name"].toString();
        out["transitDirection"]   = transit["transitdirection_id"].toString();

        const QString laneType = transit["lanetype_id"].toString();

        if (laneType == "VEHICLE" &&
            transit.contains("transit_info") &&
            transit["transit_info"].isObject()) {
            QJsonObject info = transit["transit_info"].toObject();
            QJsonObject outInfo;
            outInfo["color"]      = info["color"].toString();
            outInfo["macroClass"] = info["macro_class"].toString();
            outInfo["microClass"] = info["micro_class"].toString();
            outInfo["make"]       = info["make"].toString();
            outInfo["model"]      = info["model"].toString();
            outInfo["country"]    = info["country"].toString();
            outInfo["kemler"]     = info["kemler"].toString();
            out["transitInfo"]    = outInfo;
        }

        if ((laneType == "VEHICLE" || laneType == "WALK") &&
            transit.contains("transit_permissions") &&
            transit["transit_permissions"].isArray()) {
            QJsonArray perms = transit["transit_permissions"].toArray();
            if (!perms.isEmpty()) {
                QJsonObject p = perms[0].toObject();
                QJsonObject outPerm;
                outPerm["uidCode"]            = p["uid_code"].toString();
                outPerm["auth"]               = p["auth"].toString();
                outPerm["authCode"]           = p["auth_code"].toString();
                outPerm["authMessage"]        = p["auth_message"].toString();
                outPerm["permissionId"]       = p["permission_id"].toInt();
                outPerm["permissionType"]     = p["permissiontype_name"].toString();
                outPerm["ownerType"]          = p["ownertype_id"].toString();
                outPerm["vehicleId"]          = p["vehicle_id"].toInt();
                outPerm["vehiclePlate"]       = p["vehicle_plate"].toString();
                outPerm["peopleId"]           = p["people_id"].toInt();
                outPerm["peopleFullname"]     = p["people_fullname"].toString();
                outPerm["peopleBirthdayDate"] = p["people_birthday_date"].toString();
                outPerm["peopleBirthdayPlace"]= p["people_birthday_place"].toString();
                outPerm["companyId"]          = p["company_id"].toInt();
                outPerm["companyFullname"]    = p["company_fullname"].toString();
                outPerm["companyCity"]        = p["company_city"].toString();
                outPerm["companyType"]        = p["companytype_name"].toString();
                out["permission"]             = outPerm;
            }
        }

        result.append(out);
    }

    return result;
}
