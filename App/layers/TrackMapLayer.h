#ifndef TRACKMAPLAYER_H
#define TRACKMAPLAYER_H

#include "BaseTrackMapLayer.h"
#include <QGeoCoordinate>
#include <QVariantList>
#include <QTimer>
#include <QQmlEngine>
#include <models/TrackModel.h>

class TrackMapLayer : public BaseTrackMapLayer
{
    Q_OBJECT
    Q_PROPERTY(TrackModel *trackModel READ trackModel CONSTANT)
    QML_ELEMENT

public:
    explicit TrackMapLayer(QObject* parent = nullptr);

    QVariantList selectedObjects() const override { return m_selectedTracks; }

    Q_INVOKABLE void selectInRect(const QGeoCoordinate &topLeft, const QGeoCoordinate &bottomRight) override;
    Q_INVOKABLE void clearSelection() override;

    TrackModel *trackModel() const;

private:
    TrackModel* m_trackModel = nullptr;
    QVariantList m_selectedTracks;
    QTimer* m_clearTracksTimer = nullptr;
    bool m_active = false;
};

#endif // TRACKMAPLAYER_H
