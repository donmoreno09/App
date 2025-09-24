#ifndef SELECTIONBOXBUS_H
#define SELECTIONBOXBUS_H

#include <QObject>
#include <QGeoCoordinate>
#include <QQmlEngine>

class SelectionBoxBus : public  QObject
{
    Q_OBJECT

public:
    static SelectionBoxBus *instance()
    {
        static SelectionBoxBus *bus = new SelectionBoxBus();
        return bus;
    }

    static QObject *singletonProvider(QQmlEngine*, QJSEngine*)
    {
        return instance();
    }

signals:
    void selected(const QString& target,
                  const QGeoCoordinate& topLeft,
                  const QGeoCoordinate& bottomRight,
                  int mode);

    void deselected(const QString& target, int mode);

private:
    explicit SelectionBoxBus(QObject* parent = nullptr) : QObject(parent) {}
};

#endif // SELECTIONBOXBUS_H
