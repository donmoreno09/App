#pragma once
#include <QObject>
#include <QQmlEngine>
#include <QDateTime>
#include "models/VehicleModel.h"
#include "models/PedestrianModel.h"

class ViGateService;

class ViGateController : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    // Summary properties
    Q_PROPERTY(int totalEntries READ totalEntries NOTIFY summaryChanged)
    Q_PROPERTY(int totalExits READ totalExits NOTIFY summaryChanged)
    Q_PROPERTY(int totalVehicleEntries READ totalVehicleEntries NOTIFY summaryChanged)
    Q_PROPERTY(int totalVehicleExits READ totalVehicleExits NOTIFY summaryChanged)
    Q_PROPERTY(int totalPedestrianEntries READ totalPedestrianEntries NOTIFY summaryChanged)
    Q_PROPERTY(int totalPedestrianExits READ totalPedestrianExits NOTIFY summaryChanged)

    // Models
    Q_PROPERTY(VehicleModel* vehiclesModel READ vehiclesModel CONSTANT)
    Q_PROPERTY(PedestrianModel* pedestriansModel READ pedestriansModel CONSTANT)

    // State
    Q_PROPERTY(bool isLoading READ isLoading NOTIFY loadingChanged)
    Q_PROPERTY(bool hasData READ hasData NOTIFY hasDataChanged)
    Q_PROPERTY(bool hasError READ hasError NOTIFY hasErrorChanged)

public:
    explicit ViGateController(QObject* parent = nullptr);

    // Getters
    int totalEntries() const { return m_totalEntries; }
    int totalExits() const { return m_totalExits; }
    int totalVehicleEntries() const { return m_totalVehicleEntries; }
    int totalVehicleExits() const { return m_totalVehicleExits; }
    int totalPedestrianEntries() const { return m_totalPedestrianEntries; }
    int totalPedestrianExits() const { return m_totalPedestrianExits; }

    VehicleModel* vehiclesModel() { return m_vehiclesModel; }
    PedestrianModel* pedestriansModel() { return m_pedestriansModel; }

    bool isLoading() const { return m_loading; }
    bool hasData() const { return m_hasData; }
    bool hasError() const { return m_hasError; }

public slots:
    void fetchGateData(int gateId,
                       const QDateTime& startDate,
                       const QDateTime& endDate,
                       bool includeVehicles,
                       bool includePedestrians);
    void clearData();

signals:
    void summaryChanged();
    void loadingChanged(bool);
    void hasDataChanged(bool);
    void hasErrorChanged(bool);
    void requestFailed(const QString& error);

private:
    void setLoading(bool loading);
    void hookUpService();
    void processSummary(const QJsonObject& summary);

    // Summary data
    int m_totalEntries = 0;
    int m_totalExits = 0;
    int m_totalVehicleEntries = 0;
    int m_totalVehicleExits = 0;
    int m_totalPedestrianEntries = 0;
    int m_totalPedestrianExits = 0;

    // Models
    VehicleModel* m_vehiclesModel = nullptr;
    PedestrianModel* m_pedestriansModel = nullptr;

    // State
    bool m_loading = false;
    bool m_hasData = false;
    bool m_hasError = false;

    // Service
    ViGateService* m_service = nullptr;
    QString m_host = QStringLiteral("localhost");
    int m_port = 5002;
};
