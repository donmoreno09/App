#include "ViGateController.h"
#include "services/ViGateService.h"
#include <QJsonObject>
#include <QJsonArray>

ViGateController::ViGateController(QObject* parent)
    : QObject(parent)
    , m_vehiclesModel(new VehicleModel(this))
    , m_pedestriansModel(new PedestrianModel(this))
{
    m_service = new ViGateService(this);
    m_service->setHostPort(m_host, m_port);
    hookUpService();
}

void ViGateController::setLoading(bool loading)
{
    if (m_loading == loading) return;
    m_loading = loading;
    emit loadingChanged(loading);
}

void ViGateController::hookUpService()
{
    connect(m_service, &ViGateService::dataReady, this, [this](const QJsonObject& data) {
        if (data.contains("summary")) {
            processSummary(data["summary"].toObject());
        }

        if (data.contains("vehicles")) {
            m_vehiclesModel->setData(data["vehicles"].toArray());
        }

        if (data.contains("pedestrian")) {
            m_pedestriansModel->setData(data["pedestrian"].toArray());
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

    connect(m_service, &ViGateService::notFound, this, [this] {
        if (m_hasData) {
            m_hasData = false;
            emit hasDataChanged(false);
        }
        if (m_hasError) {
            m_hasError = false;
            emit hasErrorChanged(false);
        }
        setLoading(false);
    });

    connect(m_service, &ViGateService::requestFailed, this, [this](const QString& e) {
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
    });
}

void ViGateController::processSummary(const QJsonObject& summary)
{
    m_totalEntries = summary["total_entries"].toInt();
    m_totalExits = summary["total_exits"].toInt();
    m_totalVehicleEntries = summary["total_vehicle_entries"].toInt();
    m_totalVehicleExits = summary["total_vehicle_exits"].toInt();
    m_totalPedestrianEntries = summary["total_pedestrian_entries"].toInt();
    m_totalPedestrianExits = summary["total_pedestrian_exits"].toInt();

    emit summaryChanged();
}

void ViGateController::fetchGateData(int gateId,
                                     const QDateTime& startDate,
                                     const QDateTime& endDate,
                                     bool includeVehicles,
                                     bool includePedestrians)
{
    if (m_loading) return;

    if (m_hasData) {
        m_hasData = false;
        emit hasDataChanged(false);
    }
    if (m_hasError) {
        m_hasError = false;
        emit hasErrorChanged(false);
    }

    setLoading(true);
    m_service->getGateData(gateId, startDate, endDate, includeVehicles, includePedestrians);
}

void ViGateController::clearData()
{
    m_vehiclesModel->clear();
    m_pedestriansModel->clear();

    m_totalEntries = 0;
    m_totalExits = 0;
    m_totalVehicleEntries = 0;
    m_totalVehicleExits = 0;
    m_totalPedestrianEntries = 0;
    m_totalPedestrianExits = 0;

    emit summaryChanged();

    if (m_hasData) {
        m_hasData = false;
        emit hasDataChanged(false);
    }
}
