#include "TransitModel.h"
#include <QJsonArray>
#include <QJsonObject>
#include <QDebug>

TransitModel::TransitModel(QObject* parent)
    : QAbstractListModel(parent)
{}

int TransitModel::rowCount(const QModelIndex& parent) const
{
    if (parent.isValid()) return 0;
    return m_entries.size();
}

QVariant TransitModel::data(const QModelIndex& index, int role) const
{
    if (!index.isValid() || index.row() >= m_entries.size())
        return {};

    const auto& entry = m_entries.at(index.row());

    switch (role) {
    case TransitIdRole:
        return entry.transitId;
    case GateNameRole:
        return entry.gateName;
    case TransitStartDateRole:
        return entry.transitStartDate.toString("dd/MM/yyyy HH:mm:ss");
    case TransitEndDateRole:
        return entry.transitEndDate.toString("dd/MM/yyyy HH:mm:ss");
    case TransitStatusRole:
        return entry.transitStatus;
    case LaneTypeIdRole:
        return entry.laneTypeId;
    case LaneStatusIdRole:
        return entry.laneStatusId;
    case LaneNameRole:
        return entry.laneName;
    case TransitDirectionRole:
        return entry.transitDirection;

    // Transit Info
    case ColorRole:
        return entry.transitInfo.color;
    case MacroClassRole:
        return entry.transitInfo.macroClass;
    case MicroClassRole:
        return entry.transitInfo.microClass;
    case MakeRole:
        return entry.transitInfo.make;
    case ModelRole:
        return entry.transitInfo.model;
    case CountryRole:
        return entry.transitInfo.country;
    case KemlerRole:
        return entry.transitInfo.kemler;
    case HasTransitInfoRole:
        return entry.hasTransitInfo;

    // Permission
    case UidCodeRole:
        return entry.permission.uidCode;
    case AuthRole:
        return entry.permission.auth;
    case AuthMessageRole:
        return entry.permission.authMessage;
    case PermissionTypeRole:
        return entry.permission.permissionType;
    case VehiclePlateRole:
        return entry.permission.vehiclePlate;
    case PeopleFullnameRole:
        return entry.permission.peopleFullname;
    case CompanyFullnameRole:
        return entry.permission.companyFullname;
    case HasPermissionRole:
        return entry.hasPermission;

    default:
        return {};
    }
}

QHash<int, QByteArray> TransitModel::roleNames() const
{
    return {
        {TransitIdRole, "transitId"},
        {GateNameRole, "gateName"},
        {TransitStartDateRole, "transitStartDate"},
        {TransitEndDateRole, "transitEndDate"},
        {TransitStatusRole, "transitStatus"},
        {LaneTypeIdRole, "laneTypeId"},
        {LaneStatusIdRole, "laneStatusId"},
        {LaneNameRole, "laneName"},
        {TransitDirectionRole, "transitDirection"},

        // Transit Info
        {ColorRole, "color"},
        {MacroClassRole, "macroClass"},
        {MicroClassRole, "microClass"},
        {MakeRole, "make"},
        {ModelRole, "model"},
        {CountryRole, "country"},
        {KemlerRole, "kemler"},
        {HasTransitInfoRole, "hasTransitInfo"},

        // Permission
        {UidCodeRole, "uidCode"},
        {AuthRole, "auth"},
        {AuthMessageRole, "authMessage"},
        {PermissionTypeRole, "permissionType"},
        {VehiclePlateRole, "vehiclePlate"},
        {PeopleFullnameRole, "peopleFullname"},
        {CompanyFullnameRole, "companyFullname"},
        {HasPermissionRole, "hasPermission"}
    };
}

void TransitModel::clear()
{
    beginResetModel();
    m_entries.clear();
    endResetModel();
}

void TransitModel::setData(const QJsonArray& transitsArray)
{
    beginResetModel();
    m_entries.clear();

    for (const auto& value : transitsArray) {
        if (!value.isObject()) {
            qWarning() << "TransitModel: Skipping non-object entry";
            continue;
        }

        QJsonObject obj = value.toObject();
        TransitEntry entry;

        // Basic info
        entry.transitId = obj.value("transitId").toString();
        entry.gateName = obj.value("gateName").toString();
        entry.transitStatus = obj.value("transitStatus").toString();

        // Dates
        QString startDateStr = obj.value("transitStartDate").toString();
        entry.transitStartDate = QDateTime::fromString(startDateStr, Qt::ISODate);
        if (!entry.transitStartDate.isValid()) {
            qWarning() << "TransitModel: Invalid start date:" << startDateStr;
        }

        QString endDateStr = obj.value("transitEndDate").toString();
        entry.transitEndDate = QDateTime::fromString(endDateStr, Qt::ISODate);
        if (!entry.transitEndDate.isValid()) {
            qWarning() << "TransitModel: Invalid end date:" << endDateStr;
        }

        // Lane info
        entry.laneTypeId = obj.value("laneTypeId").toString();
        entry.laneStatusId = obj.value("laneStatusId").toString();
        entry.laneName = obj.value("laneName").toString();
        entry.transitDirection = obj.value("transitDirection").toString();

        // Transit Info (only for VEHICLE)
        if (obj.contains("transitInfo") && obj.value("transitInfo").isObject()) {
            QJsonObject infoObj = obj.value("transitInfo").toObject();
            entry.transitInfo.color = infoObj.value("color").toString();
            entry.transitInfo.macroClass = infoObj.value("macroClass").toString();
            entry.transitInfo.microClass = infoObj.value("microClass").toString();
            entry.transitInfo.make = infoObj.value("make").toString();
            entry.transitInfo.model = infoObj.value("model").toString();
            entry.transitInfo.country = infoObj.value("country").toString();
            entry.transitInfo.kemler = infoObj.value("kemler").toString();
            entry.hasTransitInfo = true;
        } else {
            entry.hasTransitInfo = false;
        }

        // Permission (first element only)
        if (obj.contains("permission") && obj.value("permission").isObject()) {
            QJsonObject permObj = obj.value("permission").toObject();
            entry.permission.uidCode = permObj.value("uidCode").toString();
            entry.permission.auth = permObj.value("auth").toString();
            entry.permission.authMessage = permObj.value("authMessage").toString();
            entry.permission.permissionType = permObj.value("permissionType").toString();
            entry.permission.vehiclePlate = permObj.value("vehiclePlate").toString();
            entry.permission.peopleFullname = permObj.value("peopleFullname").toString();
            entry.permission.companyFullname = permObj.value("companyFullname").toString();
            entry.hasPermission = true;
        } else {
            entry.hasPermission = false;
        }

        m_entries.append(entry);
    }

    qDebug() << "TransitModel: Loaded" << m_entries.size() << "transits";
    endResetModel();
}
