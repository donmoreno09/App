#include "httpclient.h"
#include <QNetworkRequest>

HttpClient::HttpClient(QObject *parent)
    : QObject(parent)
{
    connect(&m_networkManager, &QNetworkAccessManager::finished, this, &HttpClient::requestFinished);
}

void HttpClient::get(const QUrl &url)
{
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::UserAgentHeader, "Mozilla/5.0");
    request.setRawHeader("Accept", "application/json");
    request.setRawHeader("ngrok-skip-browser-warning", "69420");
    m_networkManager.get(request);
}

void HttpClient::get(const QUrl &url, Callback callback)
{
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::UserAgentHeader, "Mozilla/5.0");
    request.setRawHeader("Accept", "application/json");
    request.setRawHeader("ngrok-skip-browser-warning", "69420");

    QNetworkReply* reply = m_networkManager.get(request);
    m_callbacks.insert(reply, std::move(callback));
}

void HttpClient::requestFinished(QNetworkReply* reply)
{
    if (m_callbacks.contains(reply)) {
        Callback callback = m_callbacks.take(reply);

        if (reply->error() == QNetworkReply::NoError) {
            QByteArray data = reply->readAll();
            qDebug() << "Response content type:" << reply->header(QNetworkRequest::ContentTypeHeader).toString();
            callback(data);
        } else {
            qDebug() << "Network error:" << reply->errorString();
            qDebug() << "HTTP status code:" << reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
            callback(QByteArray());
        }
    } else {
        // GET senza callback
        if (reply->error() != QNetworkReply::NoError) {
            qDebug() << "Network error (no callback):" << reply->errorString();
            qDebug() << "HTTP status code:" << reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
        } else {
            qDebug() << "GET senza callback completata con successo";
        }
    }

    reply->deleteLater();
    emit finished(reply);  // lo emetti in ogni caso
}

void HttpClient::post(const QUrl &url, const QByteArray &body)
{
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::UserAgentHeader, "Mozilla/5.0");
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("ngrok-skip-browser-warning", "69420");

    m_networkManager.post(request, body);
}

void HttpClient::put(const QUrl &url, const QByteArray &body)
{
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::UserAgentHeader, "Mozilla/5.0");
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("ngrok-skip-browser-warning", "69420");

    m_networkManager.put(request, body);
}

void HttpClient::deleteResource(const QUrl &url)
{
    QNetworkRequest request(url);
    m_networkManager.deleteResource(request);
}
