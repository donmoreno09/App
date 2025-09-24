#include "basemaplayer.h"
#include <QDebug>

BaseMapLayer::BaseMapLayer(QObject* parent)
    : BaseLayer(parent)
{
    qDebug() << "[BaseMapLayer] Instance created";
}

double BaseMapLayer::zoomLevel() const {
    return m_zoomLevel;
}

void BaseMapLayer::setZoomLevel(double zoom) {
    if (!qFuzzyCompare(m_zoomLevel, zoom)) {
        m_zoomLevel = zoom;
        emit zoomLevelChanged();
        qDebug() << "[BaseMapLayer]" << layerName() << "→ zoom level changed to:" << zoom;
    }
}

void BaseMapLayer::handleMapClick(const QGeoCoordinate& coordinate) {
    qDebug() << "[BaseMapLayer]" << layerName() << "→ map click received at:" << coordinate;
    // Subclasses can override this method to provide custom map click behavior
}
