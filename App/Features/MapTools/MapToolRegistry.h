#ifndef TOOLREGISTRY_H
#define TOOLREGISTRY_H

#include <QObject>
#include <QQmlEngine>
#include "tools/PointTool.h"

class ToolRegistry : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(PointTool* pointTool READ pointTool CONSTANT)

public:
    explicit ToolRegistry(QObject *parent = nullptr);

    PointTool *pointTool();

private:
    PointTool m_pointTool;
};

#endif // TOOLREGISTRY_H
