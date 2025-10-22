#include "PointTool.h"

PointTool::PointTool(QObject* parent)
    : BaseTool("PointTool", parent)
{}

void PointTool::setLatitude(double latitude)
{
    m_coord.setLatitude(latitude);
    emit coordChanged();
}

void PointTool::setLongitude(double longitude)
{
    m_coord.setLongitude(longitude);
    emit coordChanged();
}

void PointTool::onTapped(const QVariant &rawEvent)
{
    if (m_editable)
        return;

    auto event = parseEvent(rawEvent);
    m_coord = event.coord;
    emit coordChanged();
    emit mapInputted();
}

void PointTool::onCancelled()
{
    BaseTool::onCancelled();
    clear();
}

void PointTool::clear()
{
    m_coord = QGeoCoordinate();
    emit coordChanged();
}

QGeoCoordinate PointTool::coord() const
{
    return m_coord;
}
