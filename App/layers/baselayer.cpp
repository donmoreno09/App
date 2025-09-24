#include "baselayer.h"
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

bool BaseLayer::isVisible() const { return m_isVisible; }

void BaseLayer::setVisible(bool visible) {
    if (m_isVisible != visible) {
        m_isVisible = visible;
        emit visibleChanged();
        qDebug() << "[BaseLayer]" << m_layerName << "→ visibility changed to:" << visible;
    }
}

bool BaseLayer::isEnabled() const { return m_isEnabled; }

void BaseLayer::setEnabled(bool enabled) {
    if (m_isEnabled != enabled) {
        m_isEnabled = enabled;
        emit enabledChanged();
        qDebug() << "[BaseLayer]" << m_layerName << "→ enabled state changed to:" << enabled;
    }
}

bool BaseLayer::isActive() const { return m_isActive; }

void BaseLayer::setActive(bool active) {
    if (m_isActive != active) {
        m_isActive = active;
        emit activeChanged();
        qDebug() << "[BaseLayer]" << m_layerName << "→ active state changed to:" << active;
    }
}

bool BaseLayer::onFocus() const { return m_onFocus; }

void BaseLayer::setFocus(bool focus) {
    if (m_onFocus != focus) {
        m_onFocus = focus;
        emit focusChanged();
        qDebug() << "[BaseLayer]" << m_layerName << "→ focus state changed to:" << focus;
    }
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
