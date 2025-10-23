#include "annotationmaplayer.h"
#include "../persistence/shapepersistencemanager.h"
#include <QDebug>
#include <core/GeoSelectionUtils.h>
#include <entities/shape.h>

AnnotationMapLayer::AnnotationMapLayer(QObject* parent)
    : BaseMapLayer(parent)
{
    setObjectName("AnnotationMapLayer");
    m_annotationModel = new VariantListModel(this);
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

VariantListModel *AnnotationMapLayer::annotationModel() const
{
    return m_annotationModel;
}
