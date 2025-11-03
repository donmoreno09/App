#ifndef TOOLCONTROLLER_H
#define TOOLCONTROLLER_H

#include <QObject>
#include <QQmlEngine>
#include <QMetaObject>
#include "tools/BaseTool.h"

class ToolController : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(QObject* inputHandler READ inputHandler WRITE setInputHandler NOTIFY inputHandlerChanged FINAL)
    Q_PROPERTY(BaseTool* activeTool READ activeTool WRITE setActiveTool NOTIFY activeToolChanged FINAL)

public:
    explicit ToolController(QObject* parent = nullptr);

    Q_INVOKABLE void test() const;

    QObject *inputHandler() const;
    void setInputHandler(QObject* inputHandler);

    BaseTool *activeTool() const;
    void setActiveTool(BaseTool *activeTool);

signals:
    void activeToolChanged();

    void inputHandlerChanged();

private:
    void connect();
    void disconnect();

    QObject* m_inputHandler;
    BaseTool* m_activeTool;
    QVector<QMetaObject::Connection> m_conns;
};

#endif // TOOLCONTROLLER_H
