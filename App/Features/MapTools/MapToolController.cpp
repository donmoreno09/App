#include "MapToolController.h"
#include <QDebug>

ToolController::ToolController(QObject *parent)
    : QObject(parent), m_activeTool(nullptr), m_inputHandler(nullptr)
{}

void ToolController::setInputHandler(QObject *inputHandler)
{
    if (m_inputHandler == inputHandler) {
        return;
    }

    disconnect();
    m_inputHandler = inputHandler;

    if (m_activeTool) {
        m_activeTool->setInputHandler(m_inputHandler);
        connect();
    }
}

BaseTool *ToolController::activeTool() const
{
    return m_activeTool;
}

void ToolController::setActiveTool(BaseTool *activeTool)
{
    if (m_activeTool == activeTool) {
        return;
    }

    if (activeTool == nullptr) {
        m_activeTool->onCancelled();
    }

    disconnect();
    m_activeTool = activeTool;

    if (m_activeTool) {
        m_activeTool->setInputHandler(m_inputHandler);
        connect();
    }

    emit activeToolChanged();
}

QObject *ToolController::inputHandler() const
{
    return m_inputHandler;
}

void ToolController::test() const
{
    qDebug() << "Test!";
}

void ToolController::connect()
{
    if (m_activeTool == nullptr || m_inputHandler == nullptr) return;

    auto tappedConn = QObject::connect(m_inputHandler, SIGNAL(tapped(QVariant)), m_activeTool, SLOT(onTapped(QVariant)));
    m_conns.append(tappedConn);
}

void ToolController::disconnect()
{
    for (const auto& conn : std::as_const(m_conns)) {
        QObject::disconnect(conn);
    }
    m_conns.clear();
}
