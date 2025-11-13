#include "annotationmaplayer.h"
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
    qWarning() << "Unimplemented: selectInRect of AnnotationMapLayer";
    emit selectedInRect();
}

void AnnotationMapLayer::clearSelection()
{
    qWarning() << "Unimplemented: clearSelection of AnnotationMapLayer";
    emit clearedSelection();
}
