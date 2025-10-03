#pragma once

#include <QObject>
#include <QDate>
#include <QDateTime>
#include <QQmlEngine>

class ShipArrivalService;

class ShipArrivalController : public QObject {
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(int  todayArrivalCount       READ todayArrivalCount       NOTIFY todayArrivalCountChanged)
    Q_PROPERTY(int  currentHourArrivalCount READ currentHourArrivalCount NOTIFY currentHourArrivalCountChanged)
    Q_PROPERTY(int  dateRangeArrivalCount   READ dateRangeArrivalCount   NOTIFY dateRangeArrivalCountChanged)
    Q_PROPERTY(int  dateTimeRangeArrivalCount READ dateTimeRangeArrivalCount NOTIFY dateTimeRangeArrivalCountChanged)
    Q_PROPERTY(bool isLoading               READ isLoading               NOTIFY loadingChanged)

public:
    explicit ShipArrivalController(QObject* parent=nullptr);

    int  todayArrivalCount() const;
    int  currentHourArrivalCount() const;
    int  dateRangeArrivalCount() const;
    int  dateTimeRangeArrivalCount() const;
    bool isLoading() const;

public slots:
    void fetchAllArrivalData();
    void fetchTodayShipArrivals();
    void fetchCurrentHourShipArrivals();
    void fetchDateRangeShipArrivals(const QDate& start, const QDate& end);
    void fetchDateTimeRangeShipArrivals(const QDateTime& start, const QDateTime& end);

signals:
    void todayArrivalCountChanged(int);
    void currentHourArrivalCountChanged(int);
    void dateRangeArrivalCountChanged(int);
    void dateTimeRangeArrivalCountChanged(int);
    void loadingChanged(bool);
    void requestFailed(const QString&);

private:
    int  m_todayArrivalCount = 0;
    int  m_currentHourArrivalCount = 0;
    int  m_dateRangeArrivalCount = 0;
    int  m_dateTimeRangeArrivalCount = 0;
    bool m_loading = false;
    int  m_pendingRequests = 0;

    ShipArrivalService* m_service = nullptr;
    QString m_host = QStringLiteral("localhost");
    int     m_port = 5002;

    void setLoading(bool loading);
    void hookUpService();
};
