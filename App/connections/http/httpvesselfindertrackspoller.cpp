#include "HttpVesselFinderTracksPoller.h"
#include <QNetworkRequest>
#include <QDebug>

HttpVesselFinderTracksPoller::HttpVesselFinderTracksPoller(const QString& url,
                                                           int intervalMs,
                                                           QObject* parent)
    : QObject(parent),
    url_(QUrl(url)),
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
    if (timer_.isActive())
        return;

    timer_.start();
    emit pollingStarted();

    qDebug() << "[HTTP-POLLER] started";
}

void HttpVesselFinderTracksPoller::stop()
{
    if (timer_.isActive()) {
        timer_.stop();
        emit pollingStopped();
    }

    abortAllReplies();

    qDebug() << "[HTTP-POLLER] stopped and replies aborted";
}

void HttpVesselFinderTracksPoller::doRequest()
{
    QNetworkRequest req(url_);

    req.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    req.setAttribute(
        QNetworkRequest::RedirectPolicyAttribute,
        QNetworkRequest::NoLessSafeRedirectPolicy
    );

    QNetworkReply* reply = manager_.get(req);
    activeReplies_.insert(reply);

    connect(reply, &QObject::destroyed, this, [this, reply]() {
        activeReplies_.remove(reply);
    });
}

void HttpVesselFinderTracksPoller::onReplyFinished(QNetworkReply* reply)
{
    activeReplies_.remove(reply);

    if (reply->error() == QNetworkReply::OperationCanceledError) {
        reply->deleteLater();
        return;
    }

    if (reply->error() != QNetworkReply::NoError) {
        emit requestError(reply->errorString());
        reply->deleteLater();
        return;
    }

    QByteArray data = reply->readAll();
    emit dataReceived(data);

    reply->deleteLater();
}

void HttpVesselFinderTracksPoller::abortAllReplies()
{
    for (QNetworkReply* reply : std::as_const(activeReplies_)) {
        if (reply && reply->isRunning()) {
            reply->abort();
        }
    }

    activeReplies_.clear();
}
