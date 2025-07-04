#include "interactionmodemanager.h"

InteractionModeManager* InteractionModeManager::instance = nullptr;

InteractionModeManager::InteractionModeManager(QObject* parent)
    : QObject(parent), m_currentMode(Cursor), m_currentSelectedShapeId("") {}

InteractionModeManager* InteractionModeManager::getInstance()
{
    if (!instance)
        instance = new InteractionModeManager();
    return instance;
}

InteractionModeManager::InteractionMode InteractionModeManager::currentMode() const {
    return m_currentMode;
}

void InteractionModeManager::setCurrentMode(InteractionMode mode) {
    if (m_currentMode != mode) {
        m_currentMode = mode;
        emit currentModeChanged();
    }
}

QString InteractionModeManager::currentSelectedShapeId() const
{
    return m_currentSelectedShapeId;
}

void InteractionModeManager::setCurrentSelectedShapeId(const QString &newCurrentSelectedShapeId)
{
    QString previousId = m_currentSelectedShapeId;
    if (m_currentSelectedShapeId == newCurrentSelectedShapeId)
        return;
    m_currentSelectedShapeId = newCurrentSelectedShapeId;
    emit currentSelectedShapeIdChanged(m_currentSelectedShapeId, previousId);
}
