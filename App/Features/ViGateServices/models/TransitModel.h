#pragma once
#include <QAbstractListModel>
#include <QQmlEngine>
#include <QJsonArray>
#include "../entities/TransitEntry.h"

class TransitModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT

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

    Q_INVOKABLE void clear();
    Q_INVOKABLE void setData(const QJsonArray& transitsArray);

private:
    QList<TransitEntry> m_entries;
};
