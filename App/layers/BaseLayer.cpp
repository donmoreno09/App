#include "BaseLayer.h"
#include <QDebug>
#include <QTimer>

BaseLayer::BaseLayer(QObject* parent)
    : QObject(parent)
{}

BaseLayer::~BaseLayer()
{}

QString BaseLayer::layerName() const { return m_layerName; }

void BaseLayer::setLayerName(const QString& name) {
    if (m_layerName != name) {
        m_layerName = name;
        emit layerNameChanged();
    }
}

QQuickItem *BaseLayer::item() const
{
    return m_item.data();
}

void BaseLayer::setItem(QQuickItem *newItem)
{
    if (m_item.data() == newItem)
        return;
    m_item = newItem;
    emit itemChanged();
}
