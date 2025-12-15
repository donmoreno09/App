#ifndef HTTPVESSELFINDERTRACKSPOLLER_H
#define HTTPVESSELFINDERTRACKSPOLLER_H

#include <QObject>
#include <QTimer>
#include <QNetworkAccessManager>
#include <QNetworkReply>

class HttpVesselFinderTracksPoller : public QObject
{
    Q_OBJECT

public:
    explicit HttpVesselFinderTracksPoller(
        const QString& url,
        int intervalMs = 2000,
        QObject* parent = nullptr
    );

    void start();
    void stop();
    bool isRunning() const { return timer_.isActive(); }

signals:
    void dataReceived(const QByteArray& data);
    void requestError(const QString& error);
    void pollingStarted();
    void pollingStopped();

private slots:
    void doRequest();
    void onReplyFinished(QNetworkReply* reply);

private:
    QString url_;
    int intervalMs_;
    QTimer timer_;
    QNetworkAccessManager manager_;
};

#endif // HTTPVESSELFINDERTRACKSPOLLER_H
