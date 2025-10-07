#ifndef TIRMAPLAYER_H
#define TIRMAPLAYER_H

#include "BaseTrackMapLayer.h"
#include <QGeoCoordinate>
#include <QVariantList>
#include <QTimer>
#include <QQmlEngine>
#include <models/TirModel.h>

class TirMapLayer : public BaseTrackMapLayer
{
    Q_OBJECT
    Q_PROPERTY(TirModel *tirModel READ tirModel CONSTANT)
    QML_ELEMENT

public:
    explicit TirMapLayer(QObject* parent = nullptr);

    QVariantList selectedObjects() const override { return m_selectedTirs; }

    Q_INVOKABLE void initialize() override;

    Q_INVOKABLE void selectInRect(const QGeoCoordinate &topLeft, const QGeoCoordinate &bottomRight) override;
    Q_INVOKABLE void clearSelection() override;

    TirModel *tirModel() const;

private:
    TirModel* m_tirModel = nullptr;
    QVariantList m_selectedTirs;
    QTimer* m_clearTirsTimer = nullptr;
    bool m_active = false;
};

#endif // TIRMAPLAYER_H
