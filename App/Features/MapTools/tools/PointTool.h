#ifndef POINTTOOL_H
#define POINTTOOL_H

#include <QObject>
#include <QtPositioning/QGeoCoordinate>
#include "BaseTool.h"

class PointTool : public BaseTool
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("Not intended for QML instantiation. Use ToolRegistry to access this instance.")

    Q_PROPERTY(QGeoCoordinate coord READ coord NOTIFY coordChanged FINAL)

public:
    explicit PointTool(QObject *parent = nullptr);

    Q_INVOKABLE void setLatitude(double latitude);

    Q_INVOKABLE void setLongitude(double longitude);

    void clear();

    QGeoCoordinate coord() const;

public slots:
    void onTapped(const QVariant &rawEvent);

    void onCancelled();

signals:
    void mapInputted();

    void coordChanged();

private:
    QGeoCoordinate m_coord;
};

#endif // POINTTOOL_H
