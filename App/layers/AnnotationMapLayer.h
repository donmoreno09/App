#ifndef ANNOTATIONMAPLAYER_H
#define ANNOTATIONMAPLAYER_H

#include "./BaseMapLayer.h"
#include <QGeoCoordinate>
#include <QVariantList>

#include "../persistence/ipersistencemanager.h"

class AnnotationMapLayer : public BaseMapLayer
{
    Q_OBJECT
    QML_ELEMENT

public:
    explicit AnnotationMapLayer(QObject* parent = nullptr);

    Q_INVOKABLE void selectInRect(const QGeoCoordinate &topLeft, const QGeoCoordinate &bottomRight) override;
    Q_INVOKABLE void clearSelection() override;

signals:
    void annotationsChanged();

private:
    IPersistenceManager* m_loader = nullptr;
};

#endif // ANNOTATIONMAPLAYER_H
