#include "TruckArrivalController.h"
#include "services/TruckArrivalService.h"
#include <QDebug>

TruckArrivalController::TruckArrivalController(QObject* parent)
    : QObject(parent)
{
    qDebug() << "[TruckArrivalController] Constructor called";
    m_service = new TruckArrivalService(this);
    m_service->setHostPort(m_host, m_port);
    hookUpService();
    qDebug() << "[TruckArrivalController] Initialized with host:" << m_host << "port:" << m_port;
}

int TruckArrivalController::todayArrivalCount() const {
    return m_todayArrivalCount;
}

int TruckArrivalController::currentHourArrivalCount() const {
    return m_currentHourArrivalCount;
}

int TruckArrivalController::dateRangeArrivalCount() const {
    return m_dateRangeArrivalCount;
}

int TruckArrivalController::dateTimeRangeArrivalCount() const {
    return m_dateTimeRangeArrivalCount;
}

bool TruckArrivalController::isLoading() const {
    return m_loading;
}

void TruckArrivalController::setLoading(bool loading) {
    if (m_loading == loading) {
        qDebug() << "[TruckArrivalController] setLoading() - no change, still:" << loading;
        return;
    }

    qDebug() << "[TruckArrivalController] setLoading() - changing from" << m_loading << "to" << loading;
    m_loading = loading;
    emit loadingChanged(loading);
    qDebug() << "[TruckArrivalController] loadingChanged(" << loading << ") signal emitted";
}

void TruckArrivalController::hookUpService() {
    qDebug() << "[TruckArrivalController] Hooking up service signals";

    connect(m_service, &TruckArrivalService::requestFailed, this, [this](const QString& e){
        qWarning() << "[TruckArrivalController] Request failed:" << e;
        qDebug() << "[TruckArrivalController] Pending requests before decrement:" << m_pendingRequests;

        emit requestFailed(e);

        if (--m_pendingRequests <= 0) {
            m_pendingRequests = 0;
            qDebug() << "[TruckArrivalController] All requests completed (with error), setting loading=false";
            setLoading(false);
        } else {
            qDebug() << "[TruckArrivalController] Still" << m_pendingRequests << "requests pending";
        }
    });

    connect(m_service, &TruckArrivalService::todayArrivalsReady, this, [this](int c){
        qDebug() << "[TruckArrivalController] todayArrivalsReady received with count:" << c;
        qDebug() << "[TruckArrivalController] Current todayArrivalCount:" << m_todayArrivalCount;
        qDebug() << "[TruckArrivalController] Pending requests before decrement:" << m_pendingRequests;

        if (m_todayArrivalCount != c) {
            m_todayArrivalCount = c;
            qDebug() << "[TruckArrivalController] Value changed, emitting todayArrivalCountChanged(" << c << ")";
            emit todayArrivalCountChanged(c);
        } else {
            qDebug() << "[TruckArrivalController] Value unchanged, not emitting signal";
        }

        if (--m_pendingRequests <= 0) {
            m_pendingRequests = 0;
            qDebug() << "[TruckArrivalController] All requests completed, setting loading=false";
            setLoading(false);
        } else {
            qDebug() << "[TruckArrivalController] Still" << m_pendingRequests << "requests pending";
        }
    });

    connect(m_service, &TruckArrivalService::currentHourArrivalsReady, this, [this](int c){
        qDebug() << "[TruckArrivalController] currentHourArrivalsReady received with count:" << c;
        qDebug() << "[TruckArrivalController] Current currentHourArrivalCount:" << m_currentHourArrivalCount;
        qDebug() << "[TruckArrivalController] Pending requests before decrement:" << m_pendingRequests;

        if (m_currentHourArrivalCount != c) {
            m_currentHourArrivalCount = c;
            qDebug() << "[TruckArrivalController] Value changed, emitting currentHourArrivalCountChanged(" << c << ")";
            emit currentHourArrivalCountChanged(c);
        } else {
            qDebug() << "[TruckArrivalController] Value unchanged, not emitting signal";
        }

        if (--m_pendingRequests <= 0) {
            m_pendingRequests = 0;
            qDebug() << "[TruckArrivalController] All requests completed, setting loading=false";
            setLoading(false);
        } else {
            qDebug() << "[TruckArrivalController] Still" << m_pendingRequests << "requests pending";
        }
    });

    connect(m_service, &TruckArrivalService::dateRangeArrivalsReady, this, [this](int c){
        qDebug() << "[TruckArrivalController] dateRangeArrivalsReady received with count:" << c;
        qDebug() << "[TruckArrivalController] Current dateRangeArrivalCount:" << m_dateRangeArrivalCount;

        if (m_dateRangeArrivalCount != c) {
            m_dateRangeArrivalCount = c;
            qDebug() << "[TruckArrivalController] Value changed, emitting dateRangeArrivalCountChanged(" << c << ")";
            emit dateRangeArrivalCountChanged(c);
        } else {
            qDebug() << "[TruckArrivalController] Value unchanged, not emitting signal";
        }

        qDebug() << "[TruckArrivalController] Single request completed, setting loading=false";
        setLoading(false);
    });

    connect(m_service, &TruckArrivalService::dateTimeRangeArrivalsReady, this, [this](int c){
        qDebug() << "[TruckArrivalController] dateTimeRangeArrivalsReady received with count:" << c;
        qDebug() << "[TruckArrivalController] Current dateTimeRangeArrivalCount:" << m_dateTimeRangeArrivalCount;

        if (m_dateTimeRangeArrivalCount != c) {
            m_dateTimeRangeArrivalCount = c;
            qDebug() << "[TruckArrivalController] Value changed, emitting dateTimeRangeArrivalCountChanged(" << c << ")";
            emit dateTimeRangeArrivalCountChanged(c);
        } else {
            qDebug() << "[TruckArrivalController] Value unchanged, not emitting signal";
        }

        qDebug() << "[TruckArrivalController] Single request completed, setting loading=false";
        setLoading(false);
    });

    qDebug() << "[TruckArrivalController] All service signals connected";
}

void TruckArrivalController::fetchAllArrivalData() {
    qDebug() << "[TruckArrivalController] fetchAllArrivalData() called";
    qDebug() << "[TruckArrivalController] Current loading state:" << m_loading;

    if (m_loading) {
        qWarning() << "[TruckArrivalController] Already loading, skipping request";
        return;
    }

    m_pendingRequests = 2;
    qDebug() << "[TruckArrivalController] Starting 2 parallel requests, setting loading=true";
    setLoading(true);

    qDebug() << "[TruckArrivalController] Calling getTodayArrivals()";
    m_service->getTodayArrivals();

    qDebug() << "[TruckArrivalController] Calling getCurrentHourArrivals()";
    m_service->getCurrentHourArrivals();
}

void TruckArrivalController::fetchDateRangeShipArrivals(const QDate& s, const QDate& e) {
    qDebug() << "[TruckArrivalController] fetchDateRangeShipArrivals() called";
    qDebug() << "[TruckArrivalController] Date range:" << s << "to" << e;
    qDebug() << "[TruckArrivalController] Current loading state:" << m_loading;

    if (m_loading) {
        qWarning() << "[TruckArrivalController] Already loading, skipping request";
        return;
    }

    qDebug() << "[TruckArrivalController] Setting loading=true";
    setLoading(true);

    qDebug() << "[TruckArrivalController] Calling getDateRangeArrivals()";
    m_service->getDateRangeArrivals(s, e);
}

void TruckArrivalController::fetchDateTimeRangeShipArrivals(const QDateTime& s, const QDateTime& e) {
    qDebug() << "[TruckArrivalController] fetchDateTimeRangeShipArrivals() called";
    qDebug() << "[TruckArrivalController] DateTime range:" << s << "to" << e;
    qDebug() << "[TruckArrivalController] Current loading state:" << m_loading;

    if (m_loading) {
        qWarning() << "[TruckArrivalController] Already loading, skipping request";
        return;
    }

    qDebug() << "[TruckArrivalController] Setting loading=true";
    setLoading(true);

    qDebug() << "[TruckArrivalController] Calling getDateTimeRangeArrivals()";
    m_service->getDateTimeRangeArrivals(s, e);
}
