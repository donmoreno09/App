#pragma once
#include <QObject>
#include <QQmlEngine>

class TrailerPredictionService;

class TrailerPredictionController : public QObject {
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(int  prediction READ prediction NOTIFY predictionChanged)
    Q_PROPERTY(bool isLoading  READ isLoading  NOTIFY loadingChanged)
    Q_PROPERTY(bool hasPrediction READ hasPrediction NOTIFY hasPredictionChanged)
    Q_PROPERTY(bool hasError      READ hasError      NOTIFY hasErrorChanged)

public:
    explicit TrailerPredictionController(QObject* parent=nullptr);

    int  prediction() const { return m_prediction; }
    bool isLoading()  const { return m_loading; }
    bool hasPrediction() const { return m_hasPrediction; }
    bool hasError()      const { return m_hasError; }

public slots:
    void fetchPredictionByTrailerId(int trailerId);

signals:
    void predictionChanged(int);
    void loadingChanged(bool);
    void requestFailed(const QString&);
    void hasPredictionChanged(bool);
    void hasErrorChanged(bool);

private:
    int  m_prediction = -1;
    bool m_loading    = false;
    bool m_hasPrediction = false;
    bool m_hasError      = false;

    TrailerPredictionService* m_service = nullptr;
    QString m_host = QStringLiteral("localhost");
    int     m_port = 5002;

    void setLoading(bool loading);
    void hookUpService();
};
