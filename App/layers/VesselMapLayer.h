#ifndef VESSELMAPLAYER_H
#define VESSELMAPLAYER_H

#include <QGeoCoordinate>
#include <QVariantList>
#include <QTimer>
#include <QQmlEngine>

#include "BaseTrackMapLayer.h"
#include "models/VesselModel.h"

class VesselMapLayer : public BaseTrackMapLayer
{
    Q_OBJECT
    Q_PROPERTY(VesselModel *vesselModel READ vesselModel CONSTANT)
    QML_ELEMENT

public:
    explicit VesselMapLayer(QObject* parent = nullptr);

    QVariantList selectedObjects() const override { return m_selectedVessels; }

    Q_INVOKABLE void selectInRect(const QGeoCoordinate &topLeft, const QGeoCoordinate &bottomRight) override;
    Q_INVOKABLE void clearSelection() override;

    VesselModel *vesselModel() const;

private:
    VesselModel*  m_vesselModel       = nullptr;
    QVariantList  m_selectedVessels;
    QTimer*       m_clearVesselsTimer = nullptr;
};

#endif // VESSELMAPLAYER_H
