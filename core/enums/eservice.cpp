#include "eservice.h"

//EServiceStatusClass

static void qRegister()
{
    qRegisterMetaType<EServiceStatus>("EServiceStatus");
    qmlRegisterUncreatableType<EServiceStatusClass>("qml.service.status", 1, 0, "EServiceStatus", "Not creatable as it is an enum type");
}

Q_COREAPP_STARTUP_FUNCTION(qRegister);

QList<QString> EServiceStatusClass::getAllValues()
{
    QList<QString> l;
    QMetaEnum e;
    e = QMetaEnum::fromType<EServiceStatus>();

    for (int k = 0; k < e.keyCount(); k++)
    {

        const QString s = QString(e.key(k));
        l.append(s);
    }

    return l;
}

EServiceStatusClass::Value EServiceStatusClass::getValueFromString(QString val)
{
    QMetaEnum e;
    e = QMetaEnum::fromType<EServiceStatus>();

    for (int k = 0; k < e.keyCount(); k++)
    {
        if (QString(e.key(k)).toLower() == val.toLower())
            return static_cast<EServiceStatus>(e.keyToValue(e.key(k)));
    }

    return EServiceStatusClass::UNKNOWN;
}

EServiceStatusClass::Value EServiceStatusClass::getValueFromStringMapping(QString val)
{
    if (val.toLower() == "connected")
        return EServiceStatus::CONNECTED;
    else if(val.toLower()=="disconnected")
        return EServiceStatus::DISCONNECTED;
    else if(val.toLower()=="connecting")
        return EServiceStatus::CONNECTING;

    return EServiceStatus::UNKNOWN;
}

QString EServiceStatusClass::getStringFromValue(EServiceStatusClass::Value val)
{
    QMetaEnum e;
    e = QMetaEnum::fromType<EServiceStatus>();

    for (int k = 0; k < e.keyCount(); k++)
        if ((e.value(k) == val))
            return QString(e.key(k));

    return "";
}
