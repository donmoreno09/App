#ifndef BASEMAPLAYER_H
#define BASEMAPLAYER_H

#include "./BaseLayer.h"

#include <QGeoCoordinate>
#include <QQuickItem>
#include <QPointer>
#include "../persistence/ipersistable.h"

class BaseMapLayer : public BaseLayer
{
    Q_OBJECT

    // Qt does not expose the C++ class of the Map QML object.
    // Therefore, to manipulate its properties, QQmlProperty is
    // used as shown by the zoomLevel helper methods.
    Q_PROPERTY(QQuickItem* map READ map WRITE setMap NOTIFY mapChanged FINAL)

public:
    explicit BaseMapLayer(QObject* parent = nullptr);
    virtual QVariantList selectedObjects() const = 0;

    virtual void loadData() = 0;
    virtual void handleLoadedObjects(const QList<IPersistable*>& objects) = 0;

    Q_INVOKABLE virtual void selectInRect(const QGeoCoordinate &topLeft, const QGeoCoordinate &bottomRight) = 0;
    Q_INVOKABLE virtual void clearSelection() = 0;

    Q_INVOKABLE double zoomLevel() const;
    Q_INVOKABLE void setZoomLevel(double zoom);

    QQuickItem *map() const;
    void setMap(QQuickItem *newMap);

signals:
    void mapChanged();
    void selectedInRect();
    void clearedSelection();

private:
    QPointer<QQuickItem> m_map;
};

#endif // BASEMAPLAYER_H
