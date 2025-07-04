#ifndef TRAILERSPREDICTIONSCONTROLLER_H
#define TRAILERSPREDICTIONSCONTROLLER_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>

class TrailersPredictionsController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int prediction READ prediction NOTIFY predictionChanged)
    Q_PROPERTY(bool isLoading READ isLoading NOTIFY loadingChanged)

public:
    explicit TrailersPredictionsController(QObject *parent = nullptr);

    int prediction() const;
    bool isLoading() const;

public slots:
    void fetchPredictionByTrailerId(int trailerId);

signals:
    void predictionChanged(int prediction);
    void requestFailed(const QString &error);
    void loadingChanged(bool loading);

private:
    QNetworkAccessManager *m_manager;
    QString m_host = "localhost";
    int m_port = 5002;
    int m_prediction = -1;
    bool m_loading = false;

    void handleNetworkReply(QNetworkReply *reply);
    void setLoading(bool loading);
};

#endif // TRAILERSPREDICTIONSCONTROLLER_H
