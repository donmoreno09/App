#pragma once
#include <QObject>
#include <QNetworkAccessManager>
#include <QUrl>

class TrailerPredictionService : public QObject
{
    Q_OBJECT
public:
    explicit TrailerPredictionService(QObject* parent = nullptr);

    void setHostPort(const QString& host, int port);

    Q_INVOKABLE void getPredictionByTrailerId(int trailerId);

signals:
    void predictionReady(int minutes);
    void requestFailed(const QString& error);
    void notFound();

private:

    QNetworkAccessManager m_manager;
    QString m_host = QStringLiteral("localhost");
    int m_port = 5002;

    void performGet(const QUrl& url);
    static QUrl makeUrl(const QString& host, int port,
                        const QString& path,
                        const std::function<void(QUrlQuery&)>& addQuery = nullptr);
};
