#include "TrailerPredictionController.h"
#include "services/TrailerPredictionService.h"

TrailerPredictionController::TrailerPredictionController(QObject* parent)
    : QObject(parent)
{
    m_service = new TrailerPredictionService(this);
    m_service->setHostPort(m_host, m_port);
    hookUpService();
}

void TrailerPredictionController::setLoading(bool loading) {
    if (m_loading == loading) return;
    m_loading = loading; emit loadingChanged(loading);
}

void TrailerPredictionController::hookUpService() {
    connect(m_service, &TrailerPredictionService::predictionReady, this, [this](int v){
        qDebug() << "[Controller] predictionReady received:" << v;
        if (m_prediction != v) { m_prediction = v; emit predictionChanged(v); }
        if (!m_hasPrediction) { m_hasPrediction = true; emit hasPredictionChanged(true); }
        if (m_hasError)       { m_hasError = false;     emit hasErrorChanged(false); }
        setLoading(false);
    });

    connect(m_service, &TrailerPredictionService::notFound, this, [this]{
        qDebug() << "[Controller] notFound received";
        qDebug() << "[Controller] Current state - prediction:" << m_prediction << "hasPrediction:" << m_hasPrediction << "hasError:" << m_hasError;

        if (m_hasPrediction)  {
            m_hasPrediction = false;
            qDebug() << "[Controller] Setting hasPrediction = false";
            emit hasPredictionChanged(false);
        }
        if (!m_hasError) {
            m_hasError = true;
            qDebug() << "[Controller] Setting hasError = true";
            emit hasErrorChanged(true);
        }
        if (m_prediction != -1) {
            m_prediction = -1;
            qDebug() << "[Controller] Setting prediction = -1";
            emit predictionChanged(-1);
        }

        qDebug() << "[Controller] Final state - prediction:" << m_prediction << "hasPrediction:" << m_hasPrediction << "hasError:" << m_hasError;
        setLoading(false);
    });

    connect(m_service, &TrailerPredictionService::requestFailed, this, [this](const QString &e){
        qDebug() << "[Controller] requestFailed received:" << e;
        emit requestFailed(e);
        if (!m_hasError)      { m_hasError = true;       emit hasErrorChanged(true); }
        if (m_hasPrediction)  { m_hasPrediction = false; emit hasPredictionChanged(false); }
        setLoading(false);
    });
}

void TrailerPredictionController::fetchPredictionByTrailerId(int id) {
    if (m_loading) return;
    if (m_hasPrediction) { m_hasPrediction = false; emit hasPredictionChanged(false); }
    if (m_hasError)      { m_hasError = false;      emit hasErrorChanged(false); }
    setLoading(true);
    m_service->getPredictionByTrailerId(id);
}
