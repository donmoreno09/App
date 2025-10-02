#include "TirModel.h"

TirModel::TirModel(QObject *parent)
    : QAbstractListModel(parent)
{}

int TirModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;

    return m_tirs.size();
}

QVariant TirModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid()) return {};
    if (index.row() < 0 || index.row() >= m_tirs.size()) return {};

    const auto& tir = m_tirs[index.row()];
    switch (role) {
    case OperationCodeRole: return tir.operationCode;
    case PosRole: return QVariant::fromValue(tir.pos);
    case CogRole: return tir.cog;
    case TimeRole: return tir.time;
    case VelRole: return QVariant::fromValue(tir.vel);
    case StateRole: return tir.state;
    default: return {};
    }
}

QHash<int, QByteArray> TirModel::roleNames() const
{
    return {
        { OperationCodeRole, "operationCode" },
        { PosRole, "pos" },
        { CogRole, "cog" },
        { TimeRole, "time" },
        { VelRole, "vel" },
        { StateRole, "state" },
    };
}

Qt::ItemFlags TirModel::flags(const QModelIndex &index) const
{
    if (!index.isValid())
        return Qt::NoItemFlags;

    return Qt::ItemIsSelectable;
}

QVector<Tir> &TirModel::tirs()
{
    return m_tirs;
}

void TirModel::setTirs(const QVector<Tir> &tirs)
{

    beginResetModel();
    m_tirs = tirs;
    endResetModel();
}

void TirModel::clear()
{
    beginResetModel();
    m_tirs.clear();
    endResetModel();
}
