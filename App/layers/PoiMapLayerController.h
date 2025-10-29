#ifndef POIMAPLAYERCONTROLLER_H
#define POIMAPLAYERCONTROLLER_H

#include "./BaseMapLayer.h"
#include <QGeoCoordinate>
#include <QVariantList>
#include <models/PoiModel.h>

class PoiMapLayerController : public BaseMapLayer
{
    Q_OBJECT
    QML_ELEMENT

public:
    explicit PoiMapLayerController(QObject* parent = nullptr);

    QVariantList selectedObjects() const override;

    Q_INVOKABLE void initialize();

    Q_INVOKABLE void selectInRect(const QGeoCoordinate &topLeft, const QGeoCoordinate &bottomRight) override;
    Q_INVOKABLE void clearSelection() override;

    PoiModel *poiModel() const; // Use the singleton PoiModel in QML

private:
    PoiModel *m_poiModel;
    QVariantList m_selectedPois;
};

#endif // POIMAPLAYERCONTROLLER_H
