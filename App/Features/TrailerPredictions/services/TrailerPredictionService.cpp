#include "TrailerPredictionService.h"

#include <QNetworkRequest>
#include <QNetworkReply>
#include <QUrl>
#include <QUrlQuery>
#include <QScopeGuard>

#include "../TrailerPredictionsLogger.h"

namespace {
Logger& _logger()
{
    static Logger logger = TrailerPredictionsLogger::get().child({
        {"service", "TRAILER_PREDICTION_SERVICE"}
    });
    return logger;
}
}

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
    _logger().info("Sending trailer prediction request", {
        kv("url", url.toString())
    });

    QNetworkRequest req(url);
    req.setRawHeader("Accept", "application/json");

    QNetworkReply* reply = m_manager.get(req);
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        const auto finish = qScopeGuard([&] { reply->deleteLater(); });

        const int status = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();

        if (status == 404) {
            _logger().info("Trailer prediction not found", {
                kv("status", status)
            });
            emit notFound();
            return;
        }

        if (reply->error() != QNetworkReply::NoError) {
            _logger().warn("Trailer prediction request failed", {
                kv("status", status),
                kv("errorCode", static_cast<int>(reply->error())),
                kv("error", reply->errorString())
            });
            emit requestFailed(reply->errorString());
            return;
        }

        if (status < 200 || status >= 300) {
            _logger().warn("Trailer prediction request returned unexpected HTTP status", {
                kv("status", status)
            });
            emit requestFailed(QStringLiteral("HTTP %1").arg(status));
            return;
        }

        const QByteArray rawData = reply->readAll();
        if (rawData.isEmpty()) {
            _logger().warn("Trailer prediction response was empty");
            emit notFound();
            return;
        }

        QString cleanData = QString::fromUtf8(rawData).trimmed();

        if (cleanData.startsWith('"') && cleanData.endsWith('"')) {
            cleanData = cleanData.mid(1, cleanData.length() - 2);
        }

        bool ok = false;
        const int value = cleanData.toInt(&ok);

        if (!ok || cleanData.isEmpty()) {
            _logger().warn("Failed to parse trailer prediction response", {
                kv("response", cleanData)
            });
            emit notFound();
            return;
        }

        _logger().info("Trailer prediction received successfully", {
            kv("prediction", value)
        });
        emit predictionReady(value);
    });
}

void TrailerPredictionService::getPredictionByTrailerId(int trailerId)
{
    _logger().info("Fetching prediction by trailer id", {
        kv("trailerId", trailerId)
    });

    const auto url = makeUrl(
        m_host,
        m_port,
        QStringLiteral("/TrailersPredictions/GetTrailerPredictionsByTrailerId/%1").arg(trailerId)
    );

    performGet(url);
}
