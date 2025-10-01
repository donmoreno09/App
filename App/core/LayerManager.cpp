#include "LayerManager.h"
#include <QDebug>

LayerManager::LayerManager(QObject* parent)
    : QObject(parent)
{}

void LayerManager::registerLayer(BaseLayer* layer) {
    if (!layer) return;

    m_layers.insert(layer);
    m_pending.insert(layer);
    connect(layer, &BaseLayer::ready, this, &LayerManager::onLayerReady, Qt::UniqueConnection);

    emit layerListChanged();
    emit layerNamesChanged();

    qDebug() << "[LayerManager] Registered layer:" << layer->layerName();
}

void LayerManager::unregisterLayer(BaseLayer* layer) {
    if (m_layers.remove(layer)) {
        qDebug() << "[LayerManager] Unregistered layer:" << layer->layerName();
        emit layerListChanged();
        emit layerNamesChanged();
    }
}

void LayerManager::onLayerReady()
{
    auto* layer = qobject_cast<BaseLayer*>(sender());
    if (!layer) return;

    m_pending.remove(layer);
    if (m_pending.empty()) {
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
