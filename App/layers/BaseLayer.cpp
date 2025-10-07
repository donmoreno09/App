#include "BaseLayer.h"
#include <QDebug>
#include <QTimer>

BaseLayer::BaseLayer(QObject* parent)
    : QObject(parent)
{
    // Initial state is set via default member initializers
}

BaseLayer::~BaseLayer()
{
    qDebug() << "[BaseLayer] Destroyed:" << m_layerName;
}

QString BaseLayer::layerName() const { return m_layerName; }

void BaseLayer::setLayerName(const QString& name) {
    if (m_layerName != name) {
        qDebug() << "[BaseLayer] Layer name changed from" << m_layerName << "to:" << name;
        m_layerName = name;
        emit layerNameChanged();
    }
}

void BaseLayer::initialize() {
    QTimer::singleShot(0, this, [this]() {
        qDebug() << "[BaseLayer:initialize] Layer is ready:" << layerName();
        emit ready();
    });
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
