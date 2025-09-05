#include "econtrollers.h"

static void qRegister()
{
    qRegisterMetaType<EControllers>("EControllers");
    qmlRegisterUncreatableType<EControllersClass>("qml.econtrollers", 1, 0, "EControllers", "Not creatable as it is an enum type");
}

Q_COREAPP_STARTUP_FUNCTION(qRegister);

QList<QString> EControllersClass::getAllValues()
{
    QList<QString> l;
    QMetaEnum e;
    e = QMetaEnum::fromType<EControllers>();

    for (int k = 0; k < e.keyCount(); k++)
    {

        const QString s = QString(e.key(k));
        l.append(s);
    }

    return l;
}

EControllersClass::Value EControllersClass::getValueFromString(QString val)
{
    QMetaEnum e;
    e = QMetaEnum::fromType<EControllers>();

    for (int k = 0; k < e.keyCount(); k++)
    {
        if (QString(e.key(k)).toLower() == val.toLower())
            return static_cast<EControllers>(e.keyToValue(e.key(k)));
    }

    return EControllersClass::Unknown;
}

EControllersClass::Value EControllersClass::getValueFromOrientModule(QString val)
{
    if (val.toLower() == "mapservice")
        return EControllers::WmsMapController;
    else if(val.toLower()=="trackservice")
        return EControllers::TrackManager;
    else if(val.toLower()=="videoservice")
        return EControllers::VideoController;
    else if(val.toLower() =="trackdetails")
        return EControllers::TrackDetails;
    else if(val.toLower() =="ownshipservice")
        return EControllers::OwnPosition;

    return EControllers::Unknown;
}

QString EControllersClass::getStringFromValue(EControllersClass::Value val)
{
    QMetaEnum e;
    e = QMetaEnum::fromType<EControllers>();

    for (int k = 0; k < e.keyCount(); k++)
        if ((e.value(k) == val))
            return QString(e.key(k));

    return "";
}


