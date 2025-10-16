#include "MapToolRegistry.h"

ToolRegistry::ToolRegistry(QObject *parent)
    : QObject{parent}
{}

PointTool *ToolRegistry::pointTool()
{
    return &m_pointTool;
}
