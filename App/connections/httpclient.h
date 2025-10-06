#ifndef HTTPCLIENT_H
#define HTTPCLIENT_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QHash>
#include <functional>
#include <QByteArray>
#include <QUrl>

class HttpClient : public QObject
{
    Q_OBJECT
public:
    using Callback = std::function<void(QByteArray)>;

    explicit HttpClient(QObject *parent = nullptr);

    void get(const QUrl &url);
    void get(const QUrl &url, Callback callback);

    void post(const QUrl &url, const QByteArray &body);
    void put(const QUrl &url, const QByteArray &body);
    void deleteResource(const QUrl &url);

private slots:
    void requestFinished(QNetworkReply *reply);

signals:
    void finished(QNetworkReply* reply);
private:
    QNetworkAccessManager m_networkManager;
    QHash<QNetworkReply*, Callback> m_callbacks;
};

#endif // HTTPCLIENT_H
