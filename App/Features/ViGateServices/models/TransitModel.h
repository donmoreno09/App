#pragma once
#include <QAbstractListModel>
#include <QDateTime>
#include <QQmlEngine>
#include <QJsonArray>

struct TransitInfo {
    QString color;
    QString macroClass;
    QString microClass;
    QString make;
    QString model;
    QString country;
    QString kemler;
};

struct TransitPermission {
    QString uidCode;
    QString auth;
    QString authCode;
    QString authMessage;
    int permissionId;
    QString permissionType;
    QString ownerType;
    int vehicleId;
    QString vehiclePlate;
    int peopleId;
    QString peopleFullname;
    QString peopleBirthdayDate;
    QString peopleBirthdayPlace;
    int companyId;
    QString companyFullname;
    QString companyCity;
    QString companyType;
};

struct TransitEntry {
    // Basic info
    QString transitId;
    QString gateName;
    QDateTime transitStartDate;
    QDateTime transitEndDate;
    QString transitStatus;

    // Lane info
    QString laneTypeId;
    QString laneStatusId;
    QString laneName;
    QString transitDirection;

    // Transit info (only for VEHICLE)
    TransitInfo transitInfo;
    bool hasTransitInfo = false;

    // Permission (first element only)
    TransitPermission permission;
    bool hasPermission = false;
};

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

        // Permission (first element) - Complete list
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
    void applyFilter();

    QString m_laneTypeFilter = "ALL";
    QList<TransitEntry> m_allEntries;  // All data (unfiltered)
    QList<TransitEntry> m_entries;     // Filtered data (displayed)
};
