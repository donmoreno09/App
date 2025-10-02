#pragma once

#include <QObject>
#include <QDate>
#include <QDateTime>
#include <QQmlEngine>               // ← per QML_ELEMENT

class ShipArrivalService;           // fwd-decl (classe privata nel .cpp)

class ShipArrivalController : public QObject {
    Q_OBJECT
    QML_ELEMENT                    // ← esponi al modulo App.Features.Arrivals

    // PROPRIETÀ INVARIATE (UI già le usa)
    Q_PROPERTY(int  todayArrivalCount       READ todayArrivalCount       NOTIFY todayArrivalCountChanged)
    Q_PROPERTY(int  currentHourArrivalCount READ currentHourArrivalCount NOTIFY currentHourArrivalCountChanged)
    Q_PROPERTY(int  dateRangeArrivalCount   READ dateRangeArrivalCount   NOTIFY dateRangeArrivalCountChanged)
    Q_PROPERTY(int  dateTimeRangeArrivalCount READ dateTimeRangeArrivalCount NOTIFY dateTimeRangeArrivalCountChanged)
    Q_PROPERTY(bool isLoading               READ isLoading               NOTIFY loadingChanged)

public:
    explicit ShipArrivalController(QObject* parent=nullptr);

    // getters invariati
    int  todayArrivalCount() const;
    int  currentHourArrivalCount() const;
    int  dateRangeArrivalCount() const;
    int  dateTimeRangeArrivalCount() const;
    bool isLoading() const;

public slots:                       // slot invariati: la UI li chiama già
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
    // stato UI (invariato)
    int  m_todayArrivalCount = 0;
    int  m_currentHourArrivalCount = 0;
    int  m_dateRangeArrivalCount = 0;
    int  m_dateTimeRangeArrivalCount = 0;
    bool m_loading = false;
    int  m_pendingRequests = 0;

    // integrazione service
    ShipArrivalService* m_service = nullptr;
    QString m_host = QStringLiteral("localhost");
    int     m_port = 5002;

    void setLoading(bool loading);
    void hookUpService();
};
