#include "HttpVesselFinderTracksPoller.h"
#include <QNetworkRequest>

HttpVesselFinderTracksPoller::HttpVesselFinderTracksPoller(const QString& url,
                                                           int intervalMs,
                                                           QObject* parent)
    : QObject(parent),
    url_(url),
    intervalMs_(intervalMs)
{
    timer_.setInterval(intervalMs_);
    timer_.setTimerType(Qt::PreciseTimer);

    connect(&timer_, &QTimer::timeout,
            this, &HttpVesselFinderTracksPoller::doRequest);

    connect(&manager_, &QNetworkAccessManager::finished,
            this, &HttpVesselFinderTracksPoller::onReplyFinished);
}

void HttpVesselFinderTracksPoller::start()
{
    if (!timer_.isActive()) {
        timer_.start();
        emit pollingStarted();
    }
}

void HttpVesselFinderTracksPoller::stop()
{
    if (timer_.isActive()) {
        timer_.stop();
        emit pollingStopped();
    }
}

void HttpVesselFinderTracksPoller::doRequest()
{
    QNetworkRequest req(url_);
    req.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    manager_.get(req);
}

void HttpVesselFinderTracksPoller::onReplyFinished(QNetworkReply* reply)
{
    if (reply->error() != QNetworkReply::NoError) {
        emit requestError(reply->errorString());
        reply->deleteLater();
        return;
    }

    QByteArray data = reply->readAll();
    emit dataReceived(data);

    reply->deleteLater();
}
