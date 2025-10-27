#pragma once
#include <QObject>
#include <QQmlEngine>
#include <QDateTime>
#include "models/TransitModel.h"

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

    // Pagination properties
    Q_PROPERTY(int currentPage READ currentPage NOTIFY paginationChanged)
    Q_PROPERTY(int totalPages READ totalPages NOTIFY paginationChanged)
    Q_PROPERTY(int totalItems READ totalItems NOTIFY paginationChanged)
    Q_PROPERTY(int pageSize READ pageSize WRITE setPageSize NOTIFY pageSizeChanged)

    // Model - Changed to single unified model
    Q_PROPERTY(TransitModel* transitsModel READ transitsModel CONSTANT)

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

    int currentPage() const { return m_currentPage; }
    int totalPages() const { return m_totalPages; }
    int totalItems() const { return m_totalItems; }
    int pageSize() const { return m_pageSize; }
    void setPageSize(int size);

    TransitModel* transitsModel() { return m_transitsModel; }

    bool isLoading() const { return m_loading; }
    bool hasData() const { return m_hasData; }
    bool hasError() const { return m_hasError; }

public slots:
    void fetchGateData(int gateId,
                       const QDateTime& startDate,
                       const QDateTime& endDate,
                       bool includeVehicles,
                       bool includePedestrians);
    void nextPage();
    void previousPage();
    void goToPage(int page);
    void clearData();

signals:
    void summaryChanged();
    void paginationChanged();
    void pageSizeChanged();
    void loadingChanged(bool);
    void hasDataChanged(bool);
    void hasErrorChanged(bool);
    void requestFailed(const QString& error);

private:
    void setLoading(bool loading);
    void hookUpService();
    void processSummary(const QJsonObject& summary);
    void fetchCurrentPage();

    // Summary data
    int m_totalEntries = 0;
    int m_totalExits = 0;
    int m_totalVehicleEntries = 0;
    int m_totalVehicleExits = 0;
    int m_totalPedestrianEntries = 0;
    int m_totalPedestrianExits = 0;

    // Pagination
    int m_currentPage = 1;
    int m_totalPages = 0;
    int m_totalItems = 0;
    int m_pageSize = 50;

    // Query parameters (stored for pagination)
    int m_gateId = 0;
    QDateTime m_startDate;
    QDateTime m_endDate;
    bool m_includeVehicles = true;
    bool m_includePedestrians = true;

    // Model - Changed to single unified model
    TransitModel* m_transitsModel = nullptr;

    // State
    bool m_loading = false;
    bool m_hasData = false;
    bool m_hasError = false;

    // Service
    ViGateService* m_service = nullptr;
    QString m_host = QStringLiteral("localhost");
    int m_port = 5005;
};
