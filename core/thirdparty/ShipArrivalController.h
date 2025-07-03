#ifndef SHIPARRIVALCONTROLLER_H
#define SHIPARRIVALCONTROLLER_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>

class ShipArrivalController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int todayArrivalCount READ todayArrivalCount NOTIFY todayArrivalCountChanged)
    Q_PROPERTY(int currentHourArrivalCount READ currentHourArrivalCount NOTIFY currentHourArrivalCountChanged)
    Q_PROPERTY(bool isLoading READ isLoading NOTIFY loadingChanged)
    Q_PROPERTY(int dateRangeArrivalCount READ dateRangeArrivalCount NOTIFY dateRangeArrivalCountChanged)
    Q_PROPERTY(int dateTimeRangeArrivalCount READ dateTimeRangeArrivalCount NOTIFY dateTimeRangeArrivalCountChanged)


public:
    explicit ShipArrivalController(QObject *parent = nullptr);

    int todayArrivalCount() const;
    int currentHourArrivalCount() const;
    bool isLoading() const;
    int dateRangeArrivalCount() const;
    int dateTimeRangeArrivalCount() const;


public slots:
    void fetchTodayShipArrivals();
    void fetchCurrentHourShipArrivals();
    void fetchAllArrivalData();
    void fetchDateRangeShipArrivals(const QDate &startDate, const QDate &endDate);
    void fetchDateTimeRangeShipArrivals(const QDateTime &startDateTime, const QDateTime &endDateTime);

signals:
    void todayArrivalCountChanged(int count);
    void currentHourArrivalCountChanged(int count);
    void todayArrivalsFetched(int count);
    void currentHourArrivalsFetched(int count);
    void requestFailed(const QString &error);
    void loadingChanged(bool loading);
    void dateRangeArrivalsFetched(int count);
    void dateRangeArrivalCountChanged(int count);
    void dateTimeRangeArrivalCountChanged(int count);


private:
    QNetworkAccessManager *m_manager;
    QString m_host = "localhost";
    int m_port = 5002;
    int m_todayArrivalCount = 0;
    int m_currentHourArrivalCount = 0;
    bool m_loading = false;
    int m_pendingRequests = 0;
    int m_dateRangeArrivalCount = -1;
    int m_dateTimeRangeArrivalCount = -1;

    void handleNetworkReply(QNetworkReply *reply, bool isTodayRequest);
    void setLoading(bool loading);
};

#endif
