#ifndef LAYERMANAGER_H
#define LAYERMANAGER_H

#include <QObject>
#include <QSet>
#include <QStringList>
#include <QVariantList>
#include "../layers/basemaplayer.h"

class BaseLayer;

class LayerManager : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QVariantList layerNames READ listLayerNames NOTIFY layerNamesChanged)
    Q_PROPERTY(QVariantList layerList READ layerList NOTIFY layerListChanged)
    Q_PROPERTY(QVariantList selectedObjects READ selectedObjects NOTIFY selectedObjectsChanged)


public:
    static LayerManager* getInstance();

    Q_INVOKABLE void registerLayer(BaseLayer* layer);
    Q_INVOKABLE void unregisterLayer(BaseLayer* layer);
    Q_INVOKABLE void notifyLayerReady(BaseLayer* layer);

    Q_INVOKABLE QVariantList listLayerNames() const;
    Q_INVOKABLE QVariantList layerList() const;

    QList<BaseLayer*> findLayersByType(const QString& typeName) const;
    BaseLayer* findLayerByName(const QString& name) const;
    BaseLayer* focusedLayer() const;
    BaseMapLayer* focusedMapLayer() const;
    QVariantList selectedObjects() const;

    Q_INVOKABLE void setFocusLayer(const QString& layerName);
    Q_INVOKABLE QString focusedLayerName() const;

signals:
    void focusChanged(const QString& layerName);
    void layerNamesChanged();
    void layerListChanged();
    void allLayersReady();
    void selectedObjectsChanged();

private:
    explicit LayerManager(QObject* parent = nullptr);
    static LayerManager* instance;

    QSet<BaseLayer*> m_layers;
    QSet<BaseLayer*> m_readyLayers;
    QString m_focusedLayer;
};

#endif // LAYERMANAGER_H
