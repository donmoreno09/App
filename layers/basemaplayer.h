#ifndef BASEMAPLAYER_H
#define BASEMAPLAYER_H

#include "./baselayer.h"

#include <QGeoCoordinate>
#include <QPolygonF>
#include <QVariantList>
#include <QList>
#include "../persistence/ipersistable.h"

class BaseMapLayer : public BaseLayer
{
    Q_OBJECT
    Q_PROPERTY(double zoomLevel READ zoomLevel WRITE setZoomLevel NOTIFY zoomLevelChanged)

public:
    explicit BaseMapLayer(QObject* parent = nullptr);
    virtual QVariantList selectedObjects() const = 0;


    double zoomLevel() const;
    void setZoomLevel(double zoom);

    Q_INVOKABLE void handleMapClick(const QGeoCoordinate& coordinate);

    virtual void loadData() = 0;
    virtual void handleLoadedObjects(const QList<IPersistable*>& objects) = 0;

signals:
    void zoomLevelChanged();

    void polygonUpdated(const QVariantList& coordinates); // for live drawing
    void polygonCompleted(const QVariantList& coordinates);
    void selectedObjectsChanged();

protected:
    double m_zoomLevel = 1.0;

    QList<QGeoCoordinate> currentPolygon;
    bool polygonInProgress = false;


protected slots:
    virtual void handleSelectionBoxSelected(const QString& target,
                                            const QGeoCoordinate& topLeft,
                                            const QGeoCoordinate& bottomRight,
                                            int mode) = 0;

    virtual void handleSelectionBoxDeselected(const QString& target, int mode) = 0;
};

#endif // BASEMAPLAYER_H
