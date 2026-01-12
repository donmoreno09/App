#include "TrailerPredictionService.h"
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QUrl>
#include <QUrlQuery>
#include <QScopeGuard>
#include <QDebug>

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
        QUrlQuery q;
        addQuery(q);
        url.setQuery(q);
    }
    return url;
}

void TrailerPredictionService::performGet(const QUrl& url)
{
    qDebug() << "[TrailerPredictionService] Requesting URL:" << url.toString();

    QNetworkRequest req(url);
    req.setRawHeader("Accept", "application/json");

    QNetworkReply* reply = m_manager.get(req);
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        const auto finish = qScopeGuard([&]{ reply->deleteLater(); });

        qDebug() << "[TrailerPredictionService] Reply received";
        qDebug() << "[TrailerPredictionService] Error:" << reply->error() << reply->errorString();

        if (reply->error() != QNetworkReply::NoError) {
            qDebug() << "[TrailerPredictionService] Network error, emitting requestFailed";
            emit requestFailed(reply->errorString());
            return;
        }

        const int status = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
        qDebug() << "[TrailerPredictionService] HTTP Status:" << status;

        if(status < 200 || status >= 300) {
            if(status == 404){
                qDebug() << "[TrailerPredictionService] 404 Not Found, emitting notFound()";
                emit notFound();
                return;
            }
            qDebug() << "[TrailerPredictionService] HTTP error, emitting requestFailed";
            emit requestFailed(QStringLiteral("HTTP %1").arg(status));
            return;
        }

        // Read the raw response
        QByteArray rawData = reply->readAll();
        qDebug() << "[TrailerPredictionService] Raw response data:" << rawData;
        qDebug() << "[TrailerPredictionService] Response size:" << rawData.size();

        if (rawData.isEmpty()) {
            qDebug() << "[TrailerPredictionService] Empty response, emitting notFound()";
            emit notFound();
            return;
        }

        QString cleanData = QString::fromUtf8(rawData).trimmed();
        qDebug() << "[TrailerPredictionService] Cleaned data:" << cleanData;

        if (cleanData.startsWith('"') && cleanData.endsWith('"')) {
            cleanData = cleanData.mid(1, cleanData.length() - 2);
            qDebug() << "[TrailerPredictionService] After removing quotes:" << cleanData;
        }

        bool ok = false;
        const int value = cleanData.toInt(&ok);
        qDebug() << "[TrailerPredictionService] Parsed int:" << value << "ok:" << ok;

        if (!ok || cleanData.isEmpty()) {
            qDebug() << "[TrailerPredictionService] Parse failed or empty, emitting notFound()";
            emit notFound();
            return;
        }

        qDebug() << "[TrailerPredictionService] Success! Emitting predictionReady(" << value << ")";
        emit predictionReady(value);
    });
}

void TrailerPredictionService::getPredictionByTrailerId(int trailerId)
{
    auto url = makeUrl(m_host, m_port, QStringLiteral("/TrailersPredictions/GetTrailerPredictionsByTrailerId/%1").arg(trailerId));
    performGet(url);
}
