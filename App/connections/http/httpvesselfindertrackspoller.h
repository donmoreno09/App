#ifndef HTTPVESSELFINDERTRACKSPOLLER_H
#define HTTPVESSELFINDERTRACKSPOLLER_H

#include <QObject>
#include <QTimer>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QSet>
#include <QUrl>

class HttpVesselFinderTracksPoller : public QObject
{
    Q_OBJECT

public:
    explicit HttpVesselFinderTracksPoller(const QString& url,
                                          int intervalMs,
                                          QObject* parent = nullptr);

    void start();
    void stop();

signals:
    void dataReceived(const QByteArray& data);
    void requestError(const QString& error);
    void pollingStarted();
    void pollingStopped();

private slots:
    void doRequest();
    void onReplyFinished(QNetworkReply* reply);

private:
    void abortAllReplies();

    QUrl url_;
    int intervalMs_;

    QTimer timer_;
    QNetworkAccessManager manager_;

    QSet<QNetworkReply*> activeReplies_;
};

#endif // HTTPVESSELFINDERTRACKSPOLLER_H
