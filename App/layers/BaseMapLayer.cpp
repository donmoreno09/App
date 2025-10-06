#include "BaseMapLayer.h"
#include <QDebug>
#include <QQmlProperty>

BaseMapLayer::BaseMapLayer(QObject* parent)
    : BaseLayer(parent)
{
    qDebug() << "[BaseMapLayer] Instance created";
}

double BaseMapLayer::zoomLevel() const {
    return QQmlProperty(m_map, "zoomLevel").read().toDouble();
}

void BaseMapLayer::setZoomLevel(double zoom) {
    if (!qFuzzyCompare(zoomLevel(), zoom)) {
        QQmlProperty(m_map, "zoomLevel").write(zoom);
        qDebug() << "[BaseMapLayer]" << layerName() << "→ zoom level changed to:" << zoom;
    }
}

QQuickItem *BaseMapLayer::map() const
{
    return m_map.data();
}

void BaseMapLayer::setMap(QQuickItem *newMap)
{
    if (m_map == newMap)
        return;
    m_map = newMap;
    emit mapChanged();
}
