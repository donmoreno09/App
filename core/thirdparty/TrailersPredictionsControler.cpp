#include "TrailersPredictionsController.h"
#include <QNetworkRequest>
#include <QUrl>
#include <QDebug>

TrailersPredictionsController::TrailersPredictionsController(QObject *parent)
    : QObject(parent), m_manager(new QNetworkAccessManager(this))
{
}

int TrailersPredictionsController::prediction() const
{
    return m_prediction;
}

bool TrailersPredictionsController::isLoading() const
{
    return m_loading;
}

void TrailersPredictionsController::setLoading(bool loading)
{
    if (m_loading != loading) {
        m_loading = loading;
        emit loadingChanged(loading);
    }
}

void TrailersPredictionsController::fetchPredictionByTrailerId(int trailerId)
{
    if (m_loading) return;

    setLoading(true);

    QUrl url(QString("http://%1:%2/TrailersPredictions/GetTrailerPredictionsByTrailerId/%3")
                 .arg(m_host).arg(m_port).arg(trailerId));

    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    QNetworkReply *reply = m_manager->get(request);
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        handleNetworkReply(reply);
    });
}

void TrailersPredictionsController::handleNetworkReply(QNetworkReply *reply)
{
    setLoading(false);

    if (reply->error() != QNetworkReply::NoError) {
        emit requestFailed(reply->errorString());
        reply->deleteLater();
        return;
    }

    QByteArray response = reply->readAll();
    bool ok;
    int prediction = response.toInt(&ok);

    if (!ok) {
        emit requestFailed("Invalid response format");
    } else {
        if (m_prediction != prediction) {
            m_prediction = prediction;
            emit predictionChanged(prediction);
        }
    }

    reply->deleteLater();
}
