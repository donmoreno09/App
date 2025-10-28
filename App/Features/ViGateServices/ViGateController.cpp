#include "ViGateController.h"
#include "services/ViGateService.h"
#include <QJsonObject>
#include <QJsonArray>

ViGateController::ViGateController(QObject* parent)
    : QObject(parent)
    , m_transitsModel(new TransitModel(this))
{
    m_service = new ViGateService(this);
    m_service->setHostPort(m_host, m_port);
    hookUpService();

    // Load active gates on initialization
    loadActiveGates();
}

void ViGateController::setLoading(bool loading)
{
    if (m_loading == loading) return;
    m_loading = loading;
    emit loadingChanged(loading);
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

    // Reset to page 1 when page size changes
    m_currentPage = 1;
    emit paginationChanged();

    // Refetch with new page size if we have query params
    if (m_gateId > 0) {
        fetchCurrentPage();
    }
}

void ViGateController::hookUpService()
{
    // Handle active gates response
    connect(m_service, &ViGateService::activeGatesReady, this, [this](const QJsonArray& gates) {
        qDebug() << "ViGateController: Received" << gates.size() << "active gates";

        m_activeGates.clear();
        for (const auto& gateValue : gates) {
            if (gateValue.isObject()) {
                QJsonObject gateObj = gateValue.toObject();
                QVariantMap gateMap;
                gateMap["id"] = gateObj["id"].toInt();
                gateMap["name"] = gateObj["name"].toString();
                m_activeGates.append(gateMap);

                qDebug() << "  - Gate" << gateMap["id"].toInt() << ":" << gateMap["name"].toString();
            }
        }

        emit activeGatesChanged();
        setLoadingGates(false);
    });

    connect(m_service, &ViGateService::dataReady, this, [this](const QJsonObject& data) {
        if (data.contains("summary")) {
            processSummary(data["summary"].toObject());
        }

        if (data.contains("transits")) {
            m_transitsModel->setData(data["transits"].toArray());
        }

        if (!m_hasData) {
            m_hasData = true;
            emit hasDataChanged(true);
        }
        if (m_hasError) {
            m_hasError = false;
            emit hasErrorChanged(false);
        }
        setLoading(false);
    });

    connect(m_service, &ViGateService::paginationInfo, this,
            [this](int currentPage, int totalPages, int totalItems) {
                m_currentPage = currentPage;
                m_totalPages = totalPages;
                m_totalItems = totalItems;
                emit paginationChanged();

                qDebug() << "ViGateController: Pagination updated - Page" << currentPage
                         << "of" << totalPages << "(" << totalItems << "total items)";
            });

    connect(m_service, &ViGateService::notFound, this, [this] {
        qDebug() << "ViGateController: Data not found (404)";

        if (m_hasData) {
            m_hasData = false;
            emit hasDataChanged(false);
        }
        if (m_hasError) {
            m_hasError = false;
            emit hasErrorChanged(false);
        }
        setLoading(false);
        setLoadingGates(false);
    });

    connect(m_service, &ViGateService::requestFailed, this, [this](const QString& e) {
        qDebug() << "ViGateController: Request failed:" << e;

        emit requestFailed(e);
        if (!m_hasError) {
            m_hasError = true;
            emit hasErrorChanged(true);
        }
        if (m_hasData) {
            m_hasData = false;
            emit hasDataChanged(false);
        }
        setLoading(false);
        setLoadingGates(false);
    });
}

void ViGateController::loadActiveGates()
{
    qDebug() << "ViGateController::loadActiveGates - Fetching active gates";
    setLoadingGates(true);
    m_service->getActiveGates();
}

void ViGateController::processSummary(const QJsonObject& summary)
{
    m_totalEntries = summary["total_entries"].toInt();
    m_totalExits = summary["total_exits"].toInt();
    m_totalVehicleEntries = summary["total_vehicle_entries"].toInt();
    m_totalVehicleExits = summary["total_vehicle_exits"].toInt();
    m_totalPedestrianEntries = summary["total_pedestrian_entries"].toInt();
    m_totalPedestrianExits = summary["total_pedestrian_exits"].toInt();

    qDebug() << "ViGateController: Summary updated";
    qDebug() << "  - Total entries:" << m_totalEntries;
    qDebug() << "  - Total exits:" << m_totalExits;
    qDebug() << "  - Vehicle entries:" << m_totalVehicleEntries;
    qDebug() << "  - Vehicle exits:" << m_totalVehicleExits;
    qDebug() << "  - Pedestrian entries:" << m_totalPedestrianEntries;
    qDebug() << "  - Pedestrian exits:" << m_totalPedestrianExits;

    emit summaryChanged();
}

void ViGateController::fetchGateData(int gateId,
                                     const QDateTime& startDate,
                                     const QDateTime& endDate,
                                     bool includeVehicles,
                                     bool includePedestrians)
{
    qDebug() << "ViGateController::fetchGateData called";
    qDebug() << "  - Gate ID:" << gateId;
    qDebug() << "  - Date range:" << startDate.toString(Qt::ISODate)
             << "to" << endDate.toString(Qt::ISODate);
    qDebug() << "  - Include vehicles:" << includeVehicles;
    qDebug() << "  - Include pedestrians:" << includePedestrians;

    // Store query parameters for pagination
    m_gateId = gateId;
    m_startDate = startDate;
    m_endDate = endDate;
    m_includeVehicles = includeVehicles;
    m_includePedestrians = includePedestrians;
    m_currentPage = 1;

    fetchCurrentPage();
}

void ViGateController::fetchCurrentPage()
{
    if (m_loading) {
        qDebug() << "ViGateController::fetchCurrentPage - Already loading, ignoring request";
        return;
    }

    qDebug() << "ViGateController::fetchCurrentPage - Page" << m_currentPage
             << "with page size" << m_pageSize;

    if (m_hasData) {
        m_hasData = false;
        emit hasDataChanged(false);
    }
    if (m_hasError) {
        m_hasError = false;
        emit hasErrorChanged(false);
    }

    setLoading(true);

    // Call the updated method with correct parameter names
    m_service->getFilteredViGateData(m_gateId, m_startDate, m_endDate,
                                     m_includePedestrians, m_includeVehicles,
                                     m_currentPage, m_pageSize);
}

void ViGateController::nextPage()
{
    if (m_currentPage < m_totalPages) {
        qDebug() << "ViGateController::nextPage - Moving from page" << m_currentPage
                 << "to" << (m_currentPage + 1);
        m_currentPage++;
        emit paginationChanged();
        fetchCurrentPage();
    } else {
        qDebug() << "ViGateController::nextPage - Already on last page";
    }
}

void ViGateController::previousPage()
{
    if (m_currentPage > 1) {
        qDebug() << "ViGateController::previousPage - Moving from page" << m_currentPage
                 << "to" << (m_currentPage - 1);
        m_currentPage--;
        emit paginationChanged();
        fetchCurrentPage();
    } else {
        qDebug() << "ViGateController::previousPage - Already on first page";
    }
}

void ViGateController::goToPage(int page)
{
    if (page >= 1 && page <= m_totalPages && page != m_currentPage) {
        qDebug() << "ViGateController::goToPage - Jumping from page" << m_currentPage
                 << "to" << page;
        m_currentPage = page;
        emit paginationChanged();
        fetchCurrentPage();
    } else {
        qDebug() << "ViGateController::goToPage - Invalid page" << page
                 << "(current:" << m_currentPage << ", total:" << m_totalPages << ")";
    }
}

void ViGateController::clearData()
{
    qDebug() << "ViGateController::clearData - Clearing all data";

    m_transitsModel->clear();

    m_totalEntries = 0;
    m_totalExits = 0;
    m_totalVehicleEntries = 0;
    m_totalVehicleExits = 0;
    m_totalPedestrianEntries = 0;
    m_totalPedestrianExits = 0;

    m_currentPage = 1;
    m_totalPages = 0;
    m_totalItems = 0;
    m_gateId = 0;

    emit summaryChanged();
    emit paginationChanged();

    if (m_hasData) {
        m_hasData = false;
        emit hasDataChanged(false);
    }
}
