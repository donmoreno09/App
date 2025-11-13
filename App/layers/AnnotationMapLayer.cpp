#include "annotationmaplayer.h"
#include "../persistence/shapepersistencemanager.h"
#include <QDebug>
#include <core/GeoSelectionUtils.h>
#include <entities/shape.h>

AnnotationMapLayer::AnnotationMapLayer(QObject* parent)
    : BaseMapLayer(parent)
{
    setObjectName("AnnotationMapLayer");
}

void AnnotationMapLayer::selectInRect(const QGeoCoordinate &topLeft, const QGeoCoordinate &bottomRight)
{
    QVariantList selectedAnnots = GeoSelection::selectInRect(m_annotationModel->data(), topLeft, bottomRight);
    qDebug() << "[AnnotationMapLayer] selectedShapes: " << selectedAnnots;
    m_selectedAnnotations = selectedAnnots;
    emit selectedInRect();
}

void AnnotationMapLayer::clearSelection()
{
    m_selectedAnnotations.clear();
    emit clearedSelection();
}
