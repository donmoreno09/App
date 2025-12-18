#include "TransitProxyModel.h"
#include "TransitModel.h"
#include <QDebug>

TransitProxyModel::TransitProxyModel(QObject* parent)
    : QSortFilterProxyModel(parent)
{
    setDynamicSortFilter(true);
}

void TransitProxyModel::setLaneTypeFilter(const QString& filter)
{
    if(m_laneTypeFilter == filter) return;

    qDebug() << "[TransitProxyModel::setLaneTypeFilter] Old: " << m_laneTypeFilter << "New:" << filter;
    m_laneTypeFilter = filter;
    emit laneTypeFilterChanged();

    invalidateFilter();
}

bool TransitProxyModel::filterAcceptsRow(int sourceRow, const QModelIndex& sourceParent) const
{
    if(m_laneTypeFilter.isEmpty() || m_laneTypeFilter == "ALL") { return true; }

    QModelIndex index = sourceModel()->index(sourceRow, 0, sourceParent);
    QString laneTypeId = sourceModel()->data(index, TransitModel::LaneTypeIdRole).toString();

    QStringList types = m_laneTypeFilter.split(',', Qt::SkipEmptyParts);
    return types.contains(laneTypeId);
}
