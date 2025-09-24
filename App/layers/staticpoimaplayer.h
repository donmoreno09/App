#ifndef STATICPOIMAPLAYER_H
#define STATICPOIMAPLAYER_H

#include "./basemaplayer.h"
#include <QGeoCoordinate>
#include <QVariantList>

#include "../persistence/ipersistencemanager.h"
#include "../core/variantlistmodel.h"

class StaticPoiMapLayer : public BaseMapLayer
{
    Q_OBJECT
    Q_PROPERTY(VariantListModel *poiModel READ poiModel CONSTANT)

public:
    explicit StaticPoiMapLayer(QObject* parent = nullptr);

    QVariantList selectedObjects() const override { return m_selectedPois; }

    Q_INVOKABLE void initialize() override;

    Q_INVOKABLE void syncSelectedObject(const QVariant& object, bool isToRemove = false);

    void loadData() override;
    void handleLoadedObjects(const QList<IPersistable*>& objects) override;

    VariantListModel *poiModel() const;

signals:
    void poisChanged();

protected slots:
    void handleSelectionBoxSelected(const QString& target,
                                    const QGeoCoordinate& topLeft,
                                    const QGeoCoordinate& bottomRight,
                                    int mode) override;

    void handleSelectionBoxDeselected(const QString& target, int mode) override;

private:
    VariantListModel* m_poiModel = nullptr;
    QVariantList m_selectedPois;
    IPersistenceManager* m_loader = nullptr;
};

#endif // STATICPOIMAPLAYER_H
