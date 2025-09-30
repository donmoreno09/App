#ifndef POIMAPLAYER_H
#define POIMAPLAYER_H

#include "./BaseMapLayer.h"
#include <QGeoCoordinate>
#include <QVariantList>

#include "../persistence/ipersistencemanager.h"
#include "../core/variantlistmodel.h"

class PoiMapLayer : public BaseMapLayer
{
    Q_OBJECT
    Q_PROPERTY(VariantListModel *poiModel READ poiModel CONSTANT)
    QML_ELEMENT

public:
    explicit PoiMapLayer(QObject* parent = nullptr);

    QVariantList selectedObjects() const override { return m_selectedPois; }

    Q_INVOKABLE void initialize() override;

    Q_INVOKABLE void selectInRect(const QGeoCoordinate &topLeft, const QGeoCoordinate &bottomRight) override;
    Q_INVOKABLE void clearSelection() override;

    void loadData() override;
    void handleLoadedObjects(const QList<IPersistable*>& objects) override;

    VariantListModel *poiModel() const;

signals:
    void poisChanged();

private:
    VariantListModel* m_poiModel = nullptr;
    QVariantList m_selectedPois;
    IPersistenceManager* m_loader = nullptr;
};

#endif // POIMAPLAYER_H
