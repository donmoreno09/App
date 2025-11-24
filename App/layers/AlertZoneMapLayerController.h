#ifndef ALERTZONEMAPLAYERCONTROLLER_H
#define ALERTZONEMAPLAYERCONTROLLER_H

#include "./BaseMapLayer.h"
#include <QGeoCoordinate>
#include <QVariantList>
#include <models/AlertZoneModel.h>

class AlertZoneMapLayerController : public BaseMapLayer
{
    Q_OBJECT
    QML_ELEMENT

public:
    explicit AlertZoneMapLayerController(QObject* parent = nullptr);

    QVariantList selectedObjects() const override;

    Q_INVOKABLE void initialize();

    Q_INVOKABLE void selectInRect(const QGeoCoordinate &topLeft, const QGeoCoordinate &bottomRight) override;
    Q_INVOKABLE void clearSelection() override;

    AlertZoneModel *alertZoneModel() const;

private:
    AlertZoneModel *m_alertZoneModel;
    QVariantList m_selectedAlertZones;
};

#endif // ALERTZONEMAPLAYERCONTROLLER_H
