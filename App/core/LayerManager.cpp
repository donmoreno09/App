#include "LayerManager.h"

#include "AppLogger.h"

// Anonymous namespace to make _logger exclusive for this file
namespace {
Logger& _logger()
{
    static Logger logger = AppLogger::get().child({
        {"service", "LAYER-MANAGER"}
    });
    return logger;
}
}

LayerManager::LayerManager(QObject* parent)
    : QObject(parent)
{}

void LayerManager::registerLayer(BaseLayer* layer) {
    if (!layer) {
        _logger().warn("Attempted to register a null layer");
        return;
    }

    m_layers.insert(layer);
    m_pending.insert(layer);
    connect(layer, &BaseLayer::ready, this, &LayerManager::onLayerReady, Qt::UniqueConnection);

    emit layerListChanged();
    emit layerNamesChanged();

    _logger().info("Registered layer", { kv("layer", layer->layerName()) });
}

void LayerManager::unregisterLayer(BaseLayer* layer) {
    if (!layer) {
        _logger().warn("Attempted to unregister a null layer");
        return;
    }

    if (m_layers.remove(layer)) {
        m_pending.remove(layer);

        _logger().info("Unregistered layer", { kv("layer", layer->layerName()) });

        emit layerListChanged();
        emit layerNamesChanged();
    }
}

void LayerManager::onLayerReady()
{
    auto* layer = qobject_cast<BaseLayer*>(sender());
    if (!layer) {
        _logger().warn("Layer ready signal received from invalid sender");
        return;
    }

    m_pending.remove(layer);
    _logger().info("Layer marked as ready", { kv("layer", layer->layerName()) });

    if (m_pending.empty()) {
        _logger().info("All layers ready");
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
