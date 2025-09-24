#ifndef ANNOTATIONMAPLAYER_H
#define ANNOTATIONMAPLAYER_H

#include "./basemaplayer.h"
#include <QGeoCoordinate>
#include <QVariantList>

#include "../persistence/ipersistencemanager.h"
#include "../core/variantlistmodel.h"

class AnnotationMapLayer : public BaseMapLayer
{
    Q_OBJECT
    Q_PROPERTY(VariantListModel *annotationModel READ annotationModel CONSTANT)

public:
    explicit AnnotationMapLayer(QObject* parent = nullptr);

    QVariantList selectedObjects() const override { return m_selectedAnnotations; }

    Q_INVOKABLE void initialize() override;

    Q_INVOKABLE void syncSelectedObject(const QVariant& object, bool isToRemove = false);

    void loadData() override;
    void handleLoadedObjects(const QList<IPersistable*>& objects) override;

    VariantListModel *annotationModel() const;

signals:
    void annotationsChanged();

protected slots:
    void handleSelectionBoxSelected(const QString& target,
                                    const QGeoCoordinate& topLeft,
                                    const QGeoCoordinate& bottomRight,
                                    int mode) override;

    void handleSelectionBoxDeselected(const QString& target, int mode) override;

private:
    VariantListModel *m_annotationModel = nullptr;
    QVariantList m_selectedAnnotations;
    IPersistenceManager* m_loader = nullptr;
};

#endif // ANNOTATIONMAPLAYER_H
