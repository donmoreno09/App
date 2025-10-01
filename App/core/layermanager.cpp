#include "layermanager.h"
#include <QDebug>

LayerManager* LayerManager::instance = nullptr;

LayerManager::LayerManager(QObject* parent)
    : QObject(parent)
{}

LayerManager* LayerManager::getInstance() {
    if (!instance)
        instance = new LayerManager();
    return instance;
}

void LayerManager::registerLayer(BaseLayer* layer) {
    if (!m_layers.contains(layer)) {
        m_layers.insert(layer);
        qDebug() << "[LayerManager] Registered layer:" << layer->layerName();
        emit layerListChanged();
        emit layerNamesChanged();
    }
}

void LayerManager::unregisterLayer(BaseLayer* layer) {
    if (m_layers.remove(layer)) {
        qDebug() << "[LayerManager] Unregistered layer:" << layer->layerName();
        emit layerListChanged();
        emit layerNamesChanged();
    }
}

void LayerManager::notifyLayerReady(BaseLayer* layer) {
    if (!layer) return;

    if (m_readyLayers.contains(layer)) {
        qDebug() << "[LayerManager] Layer already registered as ready:" << layer->layerName();
        return;
    }

    m_readyLayers.insert(layer);
    qDebug() << "[LayerManager] Layer ready:" << layer->layerName();

    bool allReady = std::all_of(m_layers.begin(), m_layers.end(), [this](BaseLayer* l) {
        return m_readyLayers.contains(l);
    });

    if (allReady) {
        qDebug() << "[LayerManager] ALL LAYERS READY!";
        emit allLayersReady();
    }
}

QVariantList LayerManager::listLayerNames() const {
    QVariantList list;
    for (auto* layer : m_layers) {
        QString name = layer->layerName();
        list << name;
    }
    return list;
}

QVariantList LayerManager::layerList() const {
    QVariantList list;
    for (BaseLayer* layer : m_layers)
        list << QVariant::fromValue(layer);  // QObject* compatibile con QML
    return list;
}

QList<BaseLayer*> LayerManager::findLayersByType(const QString& typeName) const {
    QList<BaseLayer*> result;
    for (auto* layer : m_layers) {
        if (layer->metaObject()->className() == typeName)
            result.append(layer);
    }
    return result;
}

BaseLayer* LayerManager::findLayerByName(const QString& name) const {
    for (auto* layer : m_layers) {
        if (layer->layerName() == name)
            return layer;
    }
    return nullptr;
}

QVariantList LayerManager::selectedObjects() const {
    // TO DO: Aggregate selected objects from each layer
    return QVariantList();
}
