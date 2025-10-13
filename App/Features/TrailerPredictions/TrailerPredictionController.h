#pragma once
#include <QObject>
#include <QQmlEngine>

class TrailerPredictionService;

class TrailerPredictionController : public QObject {
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(int  prediction READ prediction NOTIFY predictionChanged)
    Q_PROPERTY(bool isLoading  READ isLoading  NOTIFY loadingChanged)

public:
    explicit TrailerPredictionController(QObject* parent=nullptr);

    int  prediction() const { return m_prediction; }
    bool isLoading()  const { return m_loading; }

public slots:
    void fetchPredictionByTrailerId(int trailerId);

signals:
    void predictionChanged(int);
    void loadingChanged(bool);
    void requestFailed(const QString&);

private:
    int  m_prediction = -1;
    bool m_loading    = false;

    TrailerPredictionService* m_service = nullptr;
    QString m_host = QStringLiteral("localhost");
    int     m_port = 5002;

    void setLoading(bool loading);
    void hookUpService();
};
