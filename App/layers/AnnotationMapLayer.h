#ifndef ANNOTATIONMAPLAYER_H
#define ANNOTATIONMAPLAYER_H

#include "./BaseMapLayer.h"
#include <QGeoCoordinate>
#include <QVariantList>

#include "../persistence/ipersistencemanager.h"
#include "../core/variantlistmodel.h"

class AnnotationMapLayer : public BaseMapLayer
{
    Q_OBJECT
    Q_PROPERTY(VariantListModel *annotationModel READ annotationModel CONSTANT)
    QML_ELEMENT

public:
    explicit AnnotationMapLayer(QObject* parent = nullptr);

    QVariantList selectedObjects() const override { return m_selectedAnnotations; }

    Q_INVOKABLE void selectInRect(const QGeoCoordinate &topLeft, const QGeoCoordinate &bottomRight) override;
    Q_INVOKABLE void clearSelection() override;

    VariantListModel *annotationModel() const;

signals:
    void annotationsChanged();

private:
    VariantListModel *m_annotationModel = nullptr;
    QVariantList m_selectedAnnotations;
    IPersistenceManager* m_loader = nullptr;
};

#endif // ANNOTATIONMAPLAYER_H
