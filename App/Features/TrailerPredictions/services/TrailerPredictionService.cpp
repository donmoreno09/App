#include "TrailerPredictionService.h"
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QUrl>
#include <QUrlQuery>
#include <QScopeGuard>

TrailerPredictionService::TrailerPredictionService(QObject* parent)
    : QObject(parent)
{}

void TrailerPredictionService::setHostPort(const QString& host, int port)
{
    m_host = host;
    m_port = port;
}

QUrl TrailerPredictionService::makeUrl(const QString& host, int port,
                                        const QString& path,
                                        const std::function<void(QUrlQuery&)>& addQuery)
{
    QUrl url(QStringLiteral("http://%1:%2%3").arg(host).arg(port).arg(path));
    if (addQuery) {
        QUrlQuery q; addQuery(q); url.setQuery(q);
    }
    return url;
}

void TrailerPredictionService::performGet(RequestKind kind, const QUrl& url)
{
    QNetworkRequest req(url);
    req.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    QNetworkReply* reply = m_manager.get(req);
    connect(reply, &QNetworkReply::finished, this, [this, reply, kind]() {
        const auto finish = qScopeGuard([&]{ reply->deleteLater(); });

        if (reply->error() != QNetworkReply::NoError) {
            emit requestFailed(reply->errorString());
            return;
        }

        bool ok = false;
        const int value = reply->readAll().toInt(&ok);
        if (!ok) {
            emit requestFailed(QStringLiteral("Invalid response format"));
            return;
        }

        switch (kind) {
        case RequestKind::ByTrailerId:
            emit predictionReady(value);
            break;
        }
    });
}

void TrailerPredictionService::getPredictionByTrailerId(int trailerId)
{
    auto url = makeUrl(m_host, m_port,
                       QStringLiteral("/TrailersPredictions/GetTrailerPredictionsByTrailerId/%1")
                           .arg(trailerId));
    performGet(RequestKind::ByTrailerId, url);
}
