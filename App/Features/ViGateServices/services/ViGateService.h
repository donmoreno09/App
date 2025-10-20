#pragma once
#include <QObject>
#include <QNetworkAccessManager>
#include <QDateTime>
#include <QJsonObject>
#include <QUrl>

class ViGateService : public QObject
{
    Q_OBJECT
public:
    explicit ViGateService(QObject* parent = nullptr);

    void setHostPort(const QString& host, int port);

    Q_INVOKABLE void getGateData(int gateId,
                                 const QDateTime& startDate,
                                 const QDateTime& endDate,
                                 bool includeVehicles,
                                 bool includePedestrians);

signals:
    void dataReady(const QJsonObject& data);
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
