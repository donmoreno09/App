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
    auto event = parseEvent(rawEvent);
    m_coord = event.coord;
    emit coordChanged();
    qDebug() << "Point coordinate: " << m_coord.latitude() << ", " << m_coord.longitude();
}

void PointTool::onCancelled()
{
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
