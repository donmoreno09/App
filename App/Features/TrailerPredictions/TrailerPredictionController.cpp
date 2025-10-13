#include "TrailerPredictionController.h"
#include "services/TrailerPredictionService.h"

TrailerPredictionController::TrailerPredictionController(QObject* parent)
    : QObject(parent)
{
    m_service = new TrailerPredictionService(this);
    m_service->setHostPort(m_host, m_port);              // same as TruckArrivalController. :contentReference[oaicite:4]{index=4}
    hookUpService();
}

void TrailerPredictionController::setLoading(bool loading) {
    if (m_loading == loading) return;
    m_loading = loading; emit loadingChanged(loading);
}

void TrailerPredictionController::hookUpService() {
    connect(m_service, &TrailerPredictionService::requestFailed, this, [this](const QString& e){
        emit requestFailed(e);
        setLoading(false);                                // single call: no counter needed
    });
    connect(m_service, &TrailerPredictionService::predictionReady, this, [this](int v){
        if (m_prediction != v) { m_prediction = v; emit predictionChanged(v); }
        setLoading(false);
    });
}

void TrailerPredictionController::fetchPredictionByTrailerId(int trailerId) {
    if (m_loading) return;                                // mirrors TruckArrivalController guard. :contentReference[oaicite:5]{index=5}
    setLoading(true);
    m_service->getPredictionByTrailerId(trailerId);
}
