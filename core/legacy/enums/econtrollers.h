#ifndef ECONTROLLERS_H
#define ECONTROLLERS_H

#include <QObject>
#include <QtQml>

class EControllersClass
{
    Q_GADGET

public:
    enum Value {
        WmsMapController,
        RadialMenuController,
        TrackManager,
        TracksPanelsController,
        PanelsController,
        VideoController,
        TrackDetails,
        OwnPosition,
        CompassController,
        Unknown
    };

    Q_ENUM(Value)

    static QList<QString> getAllValues();
    static QString getStringFromValue(EControllersClass::Value val);
    static EControllersClass::Value getValueFromString(QString val);
    static EControllersClass::Value getValueFromOrientModule(QString val);

private:
    explicit EControllersClass();
};

typedef EControllersClass::Value EControllers;
#endif // ECONTROLLERS_H
