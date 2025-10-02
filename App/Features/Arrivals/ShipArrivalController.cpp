// App/Features/Arrivals/ShipArrivalController.cpp
#include "ShipArrivalController.h"
#include "internals/ShipArrivalService.h"

ShipArrivalController::ShipArrivalController(QObject* parent)
    : QObject(parent)
{
    m_service = new ShipArrivalService(this);
    m_service->setHostPort(m_host, m_port);
    hookUpService();
}

void ShipArrivalController::hookUpService() {
    connect(m_service, &ShipArrivalService::requestFailed, this, [this](const QString& e){
        emit requestFailed(e);
        if (--m_pendingRequests <= 0) { m_pendingRequests = 0; setLoading(false); }
    });
    connect(m_service, &ShipArrivalService::todayArrivalsReady, this, [this](int c){
        if (m_todayArrivalCount != c) { m_todayArrivalCount = c; emit todayArrivalCountChanged(c); }
        if (--m_pendingRequests <= 0) { m_pendingRequests = 0; setLoading(false); }
    });
    connect(m_service, &ShipArrivalService::currentHourArrivalsReady, this, [this](int c){
        if (m_currentHourArrivalCount != c) { m_currentHourArrivalCount = c; emit currentHourArrivalCountChanged(c); }
        if (--m_pendingRequests <= 0) { m_pendingRequests = 0; setLoading(false); }
    });
    connect(m_service, &ShipArrivalService::dateRangeArrivalsReady, this, [this](int c){
        if (m_dateRangeArrivalCount != c) { m_dateRangeArrivalCount = c; emit dateRangeArrivalCountChanged(c); }
        setLoading(false);
    });
    connect(m_service, &ShipArrivalService::dateTimeRangeArrivalsReady, this, [this](int c){
        if (m_dateTimeRangeArrivalCount != c) { m_dateTimeRangeArrivalCount = c; emit dateTimeRangeArrivalCountChanged(c); }
        setLoading(false);
    });
}

void ShipArrivalController::setLoading(bool b) {
    if (m_loading == b) return;
    m_loading = b;
    emit loadingChanged(b);
}

// slot invariati: ora chiamano il service
void ShipArrivalController::fetchAllArrivalData() {
    if (m_loading) return;
    m_pendingRequests = 2;
    setLoading(true);
    m_service->getTodayArrivals();
    m_service->getCurrentHourArrivals();
}
void ShipArrivalController::fetchTodayShipArrivals() {
    if (m_loading) return;
    m_pendingRequests = 1;
    setLoading(true);
    m_service->getTodayArrivals();
}
void ShipArrivalController::fetchCurrentHourShipArrivals() {
    if (m_loading) return;
    m_pendingRequests = 1;
    setLoading(true);
    m_service->getCurrentHourArrivals();
}
void ShipArrivalController::fetchDateRangeShipArrivals(const QDate& s, const QDate& e) {
    if (m_loading) return;
    setLoading(true);
    m_service->getDateRangeArrivals(s, e);
}
void ShipArrivalController::fetchDateTimeRangeShipArrivals(const QDateTime& s, const QDateTime& e) {
    if (m_loading) return;
    setLoading(true);
    m_service->getDateTimeRangeArrivals(s, e);
}

int ShipArrivalController::todayArrivalCount() const {
    return m_todayArrivalCount;
}

int ShipArrivalController::currentHourArrivalCount() const {
    return m_currentHourArrivalCount;
}

int ShipArrivalController::dateRangeArrivalCount() const {
    return m_dateRangeArrivalCount;
}

int ShipArrivalController::dateTimeRangeArrivalCount() const {
    return m_dateTimeRangeArrivalCount;
}

bool ShipArrivalController::isLoading() const {
    return m_loading;
}

