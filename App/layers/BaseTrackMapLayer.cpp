#include "BaseTrackMapLayer.h"
#include <core/GeoSelectionUtils.h>

BaseTrackMapLayer::BaseTrackMapLayer(QObject* parent)
    : BaseMapLayer(parent)
{
    setObjectName("BaseTrackMapLayer");
    m_clusterModel = new ClusterModel(this);
}

bool BaseTrackMapLayer::active() const
{
    return m_active;
}

void BaseTrackMapLayer::setActive(bool newActive)
{
    if (m_active == newActive)
        return;
    m_active = newActive;
    emit activeChanged();
}

ClusterModel *BaseTrackMapLayer::clusterModel() const
{
    return m_clusterModel;
}
