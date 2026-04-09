#include "BaseMapLayer.h"

#include <QQmlProperty>

#include "AppLogger.h"

// Anonymous namespace to make _logger exclusive for this file
namespace {
Logger& _logger()
{
    static Logger logger = AppLogger::get().child({
        {"service", "BASE-MAP-LAYER"}
    });
    return logger;
}
}

BaseMapLayer::BaseMapLayer(QObject* parent)
    : BaseLayer(parent)
{
    _logger().info("BaseMapLayer instance created");
}

double BaseMapLayer::zoomLevel() const {
    return QQmlProperty(m_map, "zoomLevel").read().toDouble();
}

void BaseMapLayer::setZoomLevel(double zoom) {
    if (!qFuzzyCompare(zoomLevel(), zoom)) {
        QQmlProperty(m_map, "zoomLevel").write(zoom);
        _logger().info("Zoom level changed", {
                                                 kv("layer", layerName()),
                                                 kv("zoom", zoom)
                                             });
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
