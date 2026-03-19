#include "VesselModel.h"
#include <limits>

VesselModel::VesselModel(QObject *parent)
    : BaseTrackModel(parent)
{}

int VesselModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;

    return m_vessels.size();
}

QVariant VesselModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid()) return {};
    if (index.row() < 0 || index.row() >= m_vessels.size()) return {};

    const auto& vessel = m_vessels[index.row()];

    switch (role) {
    case PosRole:            return QVariant::fromValue(vessel.pos);
    case CogRole:            return vessel.cog;
    case TimeRole:           return vessel.time;
    case StateRole:          return vessel.state;
    case NameRole:           return vessel.name;
    case UidForHistoryRole:  return vessel.uidForHistory;
    case HistoryRole:        return historyToVariant(vessel.history);

    case MmsiRole:           return vessel.mmsi;
    case HeadingRole:        return vessel.heading;
    case SpeedRole:          return vessel.speed;
    case ARole:              return vessel.a;
    case BRole:              return vessel.b;
    case CRole:              return vessel.c;
    case DRole:              return vessel.d;

    case ShipLengthRole:     return vessel.shipLength();
    case ShipWidthRole:      return vessel.shipWidth();
    case HasDimensionsRole:  return vessel.hasDimensions();
    case DisplayHeadingRole: return vessel.displayHeading();

    default: return {};
    }
}

QHash<int, QByteArray> VesselModel::roleNames() const
{
    return {
            { PosRole,            "pos"            },
            { CogRole,            "cog"            },
            { TimeRole,           "time"           },
            { StateRole,          "state"          },
            { NameRole,           "name"           },
            { UidForHistoryRole,  "uidForHistory"  },
            { HistoryRole,        "history"        },
            { MmsiRole,           "mmsi"           },
            { HeadingRole,        "heading"        },
            { SpeedRole,          "speed"          },
            { ARole,              "a"              },
            { BRole,              "b"              },
            { CRole,              "c"              },
            { DRole,              "d"              },
            { ShipLengthRole,     "shipLength"     },
            { ShipWidthRole,      "shipWidth"      },
            { HasDimensionsRole,  "hasDimensions"  },
            { DisplayHeadingRole, "displayHeading" },
            };
}

Qt::ItemFlags VesselModel::flags(const QModelIndex &index) const
{
    if (!index.isValid())
        return Qt::NoItemFlags;

    return Qt::ItemIsSelectable;
}

QVector<Vessel> &VesselModel::vessels()
{
    return m_vessels;
}

void VesselModel::set(const QVector<Vessel> &vessels)
{
    beginResetModel();
    m_vessels = vessels;
    endResetModel();
}

void VesselModel::upsert(const QVector<Vessel> &vessels)
{
    QSet<QString> seen;
    for (const auto& vessel : vessels)
        seen.insert(vessel.mmsi);

    for (int row = m_vessels.size() - 1; row >= 0; --row) {
        if (!seen.contains(m_vessels[row].mmsi)) {
            beginRemoveRows({}, row, row);
            m_vessels.removeAt(row);
            endRemoveRows();
        }
    }

    m_upsertMap.clear();
    m_upsertMap.reserve(m_vessels.size());
    for (int row = 0; row < m_vessels.size(); ++row)
        m_upsertMap.insert(m_vessels[row].mmsi, row);

    for (const auto& vessel : vessels) {
        auto it = m_upsertMap.find(vessel.mmsi);

        if (it != m_upsertMap.end()) {
            const int row = it.value();

            const bool historyWasEmpty      = m_vessels[row].history.isEmpty();
            const bool historyWillBeNonEmpty = !vessel.history.isEmpty();

            QVector<int> changed = diffRoles(m_vessels[row], vessel);
            if (!changed.isEmpty()) {
                m_vessels[row] = vessel;
                const QModelIndex idx = index(row);
                emit dataChanged(idx, idx, changed);
            }

            if (historyWasEmpty && historyWillBeNonEmpty) {
                emit historyPayloadArrived(
                    m_vessels[row].sourceName,
                    m_vessels[row].uidForHistory
                    );
            }

        } else {
            // New vessel: append it
            const int row = m_vessels.size();

            beginInsertRows({}, row, row);
            m_vessels.append(vessel);
            m_upsertMap.insert(vessel.mmsi, row);
            endInsertRows();

            if (!vessel.history.isEmpty())
                emit historyPayloadArrived(vessel.sourceName, vessel.uidForHistory);
        }
    }
}

QVector<int> VesselModel::diffRoles(const Vessel &a, const Vessel &b) const
{
    QVector<int> roles;

    if (!almostEqual(a.pos, b.pos))            roles << PosRole;
    if (!qFuzzyCompare(a.cog, b.cog))          roles << CogRole;
    if (a.time != b.time)                       roles << TimeRole;
    if (a.state != b.state)                     roles << StateRole;
    if (a.name != b.name)                       roles << NameRole;
    if (a.uidForHistory != b.uidForHistory)     roles << UidForHistoryRole;

    // Vessel-specific fields
    if (a.mmsi != b.mmsi)                       roles << MmsiRole;
    if (a.heading != b.heading) {
        roles << HeadingRole;
        roles << DisplayHeadingRole;
    }
    if (!qFuzzyCompare(a.speed, b.speed))       roles << SpeedRole;
    if (a.a != b.a || a.b != b.b) {
        roles << ARole << BRole << ShipLengthRole << HasDimensionsRole;
    }
    if (a.c != b.c || a.d != b.d) {
        roles << CRole << DRole << ShipWidthRole << HasDimensionsRole;
    }

    const int asz   = a.history.size();
    const int bsz   = b.history.size();
    const int alast = asz ? a.history.constLast().time : std::numeric_limits<int>::min();
    const int blast = bsz ? b.history.constLast().time : std::numeric_limits<int>::min();

    if (asz != bsz || alast != blast)
        roles << HistoryRole;

    return roles;
}

QQmlPropertyMap *VesselModel::getEditableVessel(int index)
{
    return m_helper->map(index);
}

void VesselModel::clear()
{
    beginResetModel();
    m_vessels.clear();
    endResetModel();
}

QVariant VesselModel::getRoleData(int idx, int role) const
{
    return data(index(idx), role);
}
