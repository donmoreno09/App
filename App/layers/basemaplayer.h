#ifndef BASEMAPLAYER_H
#define BASEMAPLAYER_H

#include "./BaseLayer.h"

#include <QGeoCoordinate>
#include <QPolygonF>
#include <QVariantList>
#include <QList>
#include <QPointer>
#include "../persistence/ipersistable.h"

class BaseMapLayer : public BaseLayer
{
    Q_OBJECT

    Q_PROPERTY(QObject* map READ map WRITE setMap NOTIFY mapChanged FINAL)

public:
    explicit BaseMapLayer(QObject* parent = nullptr);
    virtual QVariantList selectedObjects() const = 0;

    virtual void loadData() = 0;
    virtual void handleLoadedObjects(const QList<IPersistable*>& objects) = 0;

    Q_INVOKABLE virtual void selectInRect(const QGeoCoordinate &topLeft, const QGeoCoordinate &bottomRight) = 0;
    Q_INVOKABLE virtual void clearSelection() = 0;

    Q_INVOKABLE double zoomLevel() const;
    Q_INVOKABLE void setZoomLevel(double zoom);

    QObject *map() const;
    void setMap(QObject *newMap);

signals:
    void mapChanged();
    void selectedInRect();
    void clearedSelection();

private:
    QPointer<QObject> m_map;
};

#endif // BASEMAPLAYER_H
