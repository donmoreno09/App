#ifndef POINTTOOL_H
#define POINTTOOL_H

#include <QObject>
#include "BaseTool.h"

class PointTool : public BaseTool
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("Not intended for QML instantiation. Use ToolRegistry to access this instance.")

    Q_PROPERTY(QGeoCoordinate coord READ coord NOTIFY coordChanged FINAL)

public:
    explicit PointTool(QObject *parent = nullptr);

    QGeoCoordinate coord() const;

    Q_INVOKABLE void setLatitude(double lat);
    Q_INVOKABLE void setLongitude(double lon);
    Q_INVOKABLE void setAltitude(double altitude);

    void clear();

public slots:
    void onTapped(const QVariant &rawEvent);

    void onCancelled();

signals:
    void coordChanged();

private:
    QGeoCoordinate m_coord;
};

#endif // POINTTOOL_H
