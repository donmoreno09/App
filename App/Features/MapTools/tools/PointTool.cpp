#include "PointTool.h"

PointTool::PointTool(QObject* parent)
    : BaseTool("PointTool", parent)
{}

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

QGeoCoordinate PointTool::coord() const
{
    return m_coord;
}

void PointTool::setLatitude(double lat)
{
    m_coord.setLatitude(lat);
    emit coordChanged();
}

void PointTool::setLongitude(double lon)
{
    m_coord.setLongitude(lon);
    emit coordChanged();
}

void PointTool::setAltitude(double altitude)
{
    m_coord.setAltitude(altitude);
    emit coordChanged();
}

void PointTool::clear()
{
    m_coord = QGeoCoordinate();
    emit coordChanged();
}
