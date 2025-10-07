#include "popupmanager.h"
#include <algorithm>
#include <QDebug>

PopupManager::PopupManager(QObject* parent)
    : QObject(parent), m_baseZ(100), m_maxZ(900)
{
}

void PopupManager::bringToFront(QQuickItem* popup) {
    int idx = m_stack.indexOf(popup);
    if (idx != -1)
        m_stack.removeAt(idx);
    m_stack.append(popup);
    updateZ();

    // Ensure it can still reach maxZ if needed
    if (popup->z() == m_maxZ - 1)
        popup->setZ(m_maxZ);
}

void PopupManager::unregister(QQuickItem* popup) {
    qDebug() << "Unregistering popup:" << popup->property("title");

    int idx = m_stack.indexOf(popup);
    if (idx != -1) {
        m_stack.removeAt(idx);
        updateZ();
    }
}

void PopupManager::updateZ() {
    for (int j = 0; j < m_stack.size(); ++j) {
        qreal zval = std::min(m_baseZ + j, m_maxZ - 1);
        m_stack[j]->setZ(zval);
    }
}
