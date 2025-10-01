#pragma once

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QDateTime>
#include <QQmlEngine>
#include "TruckArrivalModel.h"

class TruckArrivalModel;

class TruckArrivalController : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(bool isLoading READ isLoading NOTIFY isLoadingChanged)
    Q_PROPERTY(QString lastError READ lastError NOTIFY errorOccurred)
    Q_PROPERTY(QUrl baseUrl READ baseUrl WRITE setBaseUrl NOTIFY baseUrlChanged)
    Q_PROPERTY(int todayCount READ todayCount NOTIFY todayCountChanged)
    Q_PROPERTY(int currentHourCount READ currentHourCount NOTIFY currentHourCountChanged)
    Q_PROPERTY(int dateRangeCount READ dateRangeCount NOTIFY dateRangeCountChanged)
    Q_PROPERTY(int dateTimeRangeCount READ dateTimeRangeCount NOTIFY dateTimeRangeCountChanged)
    Q_PROPERTY(TruckArrivalModel* model READ model WRITE setModel NOTIFY modelChanged)

public:
    explicit TruckArrivalController(QObject *parent = nullptr);

    bool isLoading() const { return m_activeRequests > 0; }
    QString lastError() const { return m_lastError; }
    QUrl baseUrl() const { return m_baseUrl; }
    void setBaseUrl(const QUrl &url);
    void setModel(TruckArrivalModel* m);

    int todayCount() const { return m_todayCount; }
    int currentHourCount() const { return m_currentHourCount; }
    int dateRangeCount() const { return m_dateRangeCount; }
    int dateTimeRangeCount() const { return m_dateTimeRangeCount; }

    TruckArrivalModel* model() const { return m_model; }

    // API methods
    Q_INVOKABLE void fetchTodayCount();
    Q_INVOKABLE void fetchCurrentHourCount();
    Q_INVOKABLE void fetchDateRangeCount(const QDate &start, const QDate &end);
    Q_INVOKABLE void fetchDateTimeRangeCount(const QDateTime &start, const QDateTime &end);

    // Convenience batch method
    Q_INVOKABLE void fetchAllBasicData(); // Today + Current Hour

signals:
    // Property change signals
    void todayCountChanged();
    void currentHourCountChanged();
    void dateRangeCountChanged();
    void dateTimeRangeCountChanged();
    void isLoadingChanged();
    void errorOccurred(QString error);
    void baseUrlChanged();
    void modelChanged();

private:
    void makeRequest(const QString &endpoint,
                     const QUrlQuery &query,
                     std::function<void(const QByteArray&)> onSuccess);

    void incrementRequests();
    void decrementRequests();
    void setError(const QString &error);

    QNetworkAccessManager *m_network;
    QUrl m_baseUrl;
    QString m_lastError;
    int m_activeRequests = 0;

    int m_todayCount = 0;
    int m_currentHourCount = 0;
    int m_dateRangeCount = -1;
    int m_dateTimeRangeCount = -1;

    TruckArrivalModel* m_model;
};

