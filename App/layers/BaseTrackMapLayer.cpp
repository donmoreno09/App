#include "BaseTrackMapLayer.h"
#include <QDebug>
#include <core/GeoSelectionUtils.h>

BaseTrackMapLayer::BaseTrackMapLayer(QObject* parent)
    : BaseMapLayer(parent)
{
    setObjectName("BaseTrackMapLayer");
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
