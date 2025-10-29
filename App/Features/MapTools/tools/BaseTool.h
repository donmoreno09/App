#ifndef BASETOOL_H
#define BASETOOL_H

#include <QDebug>
#include <QObject>
#include <QString>
#include <QPointF>
#include <QtPositioning/QGeoCoordinate>
#include <QVariant>
#include <QQmlEngine>
#include <QQmlPropertyMap>

struct ToolEvent {
    QGeoCoordinate coord;
    QPointF point;
};

class BaseTool : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QQmlPropertyMap* editable READ editable WRITE setEditable NOTIFY editableChanged FINAL)

public:
    explicit BaseTool(QString id = "BaseTool", QObject* parent = nullptr) : QObject(parent), m_id(id) { qDebug() << "Created: " << m_id; }

    virtual ~BaseTool() { qDebug() << "Destroyed:" << m_id; }

    // NOTE: This is an ad hoc solution to be able to perform geo-point conversions
    //       An alternative is to create a CoordinateUtils but until we find a way to
    //       get a singleton in C++ created in QML, this ad hoc thing remains for now.
    void setInputHandler(QObject* inputHandler) { m_inputHandler = inputHandler; }

    virtual void clear() = 0;

    QQmlPropertyMap *editable() const
    {
        return m_editable;
    }

    void setEditable(QQmlPropertyMap *newEditable)
    {
        if (m_editable == newEditable)
            return;
        m_editable = newEditable;
        emit editableChanged();
    }

public slots:
    virtual void onTapped(const QVariant &rawEvent) {}

    virtual void onCancelled() { m_editable = nullptr; }

signals:
    void editableChanged();

protected:
    QString m_id;
    QQmlPropertyMap *m_editable = nullptr;

    ToolEvent parseEvent(const QVariant &rawEvent) {
        const auto map = rawEvent.toMap();
        return {
            map["coord"].value<QGeoCoordinate>(),
            map["point"].toPointF(),
        };
    }

    QPointF geoToPoint(const QGeoCoordinate& coord) {
        QPointF point;
        QMetaObject::invokeMethod(m_inputHandler,
                                  "geoToPoint",
                                  Q_RETURN_ARG(QPointF, point),
                                  Q_ARG(QGeoCoordinate, coord));
        return point;
    }

    QGeoCoordinate pointToGeo(const QPointF& point) {
        QGeoCoordinate coord;
        QMetaObject::invokeMethod(m_inputHandler,
                                  "pointToGeo",
                                  Q_RETURN_ARG(QGeoCoordinate, coord),
                                  Q_ARG(QPointF, point));
        return coord;
    }

private:
    QObject* m_inputHandler = nullptr;
};

#endif // BASETOOL_H
