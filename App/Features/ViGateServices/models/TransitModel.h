#pragma once
#include <QAbstractListModel>
#include <QQmlEngine>
#include <QJsonArray>
#include "../entities/TransitEntry.h"

class TransitModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QString laneTypeFilter READ laneTypeFilter WRITE setLaneTypeFilter NOTIFY laneTypeFilterChanged)

public:
    enum Roles {
        TransitIdRole = Qt::UserRole + 1,
        GateNameRole,
        TransitStartDateRole,
        TransitEndDateRole,
        TransitStatusRole,
        LaneTypeIdRole,
        LaneStatusIdRole,
        LaneNameRole,
        TransitDirectionRole,

        // Transit Info (VEHICLE only)
        ColorRole,
        MacroClassRole,
        MicroClassRole,
        MakeRole,
        ModelRole,
        CountryRole,
        KemlerRole,
        HasTransitInfoRole,

        // Transit Permission
        UidCodeRole,
        AuthRole,
        AuthCodeRole,
        AuthMessageRole,
        PermissionIdRole,
        PermissionTypeRole,
        OwnerTypeRole,
        VehicleIdRole,
        VehiclePlateRole,
        PeopleIdRole,
        PeopleFullnameRole,
        PeopleBirthdayDateRole,
        PeopleBirthdayPlaceRole,
        CompanyIdRole,
        CompanyFullnameRole,
        CompanyCityRole,
        CompanyTypeRole,
        HasPermissionRole
    };

    explicit TransitModel(QObject* parent = nullptr);

    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    QString laneTypeFilter() const { return m_laneTypeFilter; }
    void setLaneTypeFilter(const QString& filter);

    Q_INVOKABLE void clear();
    Q_INVOKABLE void setData(const QJsonArray& transitsArray);

signals:
    void laneTypeFilterChanged();

private:
    // Parse JSON to TransitEntry (moved to separate function for clarity)
    TransitEntry parseTransitEntry(const QJsonObject& obj) const;

    // Check if entry passes current filter
    bool passesFilter(const TransitEntry& entry) const;

    // Apply filter incrementally without full reset
    void applyFilterIncremental();

    QString m_laneTypeFilter = "ALL";
    QList<TransitEntry> m_entries;  // Single source of truth - filtered data displayed
};
