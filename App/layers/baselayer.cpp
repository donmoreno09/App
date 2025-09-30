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
        emit layerReady();
    });
}

bool BaseLayer::active() const
{
    return m_active;
}

void BaseLayer::setActive(bool newActive)
{
    if (m_active == newActive)
        return;
    m_active = newActive;
    emit activeChanged();
}

bool BaseLayer::visible() const
{
    return m_visible;
}

void BaseLayer::setVisible(bool newVisible)
{
    if (m_visible == newVisible)
        return;
    m_visible = newVisible;
    emit visibleChanged();
}
