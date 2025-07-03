#include "basemaplayer.h"
#include <QDebug>

BaseMapLayer::BaseMapLayer(QObject* parent)
    : BaseLayer(parent)
{
    qDebug() << "[BaseMapLayer] Creato";
}

double BaseMapLayer::zoomLevel() const {
    return m_zoomLevel;
}

void BaseMapLayer::setZoomLevel(double zoom) {
    if (!qFuzzyCompare(m_zoomLevel, zoom)) {
        m_zoomLevel = zoom;
        emit zoomLevelChanged();
        qDebug() << "[BaseMapLayer]" << layerName() << "→ zoomLevel cambiato a:" << zoom;
    }
}

void BaseMapLayer::handleMapClick(const QGeoCoordinate& coordinate) {
    qDebug() << "[BaseMapLayer]" << layerName() << "→ Map click at:" << coordinate;
    // I layer derivati possono sovrascrivere questa funzione
}
