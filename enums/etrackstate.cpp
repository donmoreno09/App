#include "etrackstate.h"


static void qRegister()
{

    qRegisterMetaType<ETrackState>("ETrackState");
    qmlRegisterUncreatableType<ETrackStateClass>("qml.track.state", 1, 0, "ETrackState", "Not creatable as it is an enum type");

}

Q_COREAPP_STARTUP_FUNCTION(qRegister);


QList<QString> ETrackStateClass::getAllValues()
{

    QList<QString> l;
    QMetaEnum e;
    e = QMetaEnum::fromType<ETrackState>();

    for (int k = 0; k < e.keyCount(); k++)
    {

        const QString s = QString(e.key(k));
        l.append(s);
    }

    return l;
}

ETrackStateClass::Value ETrackStateClass::getValueFromString(QString val)
{

    QMetaEnum e;
    e = QMetaEnum::fromType<ETrackState>();

    for (int k = 0; k < e.keyCount(); k++)
    {

        if (QString(e.key(k)).toLower() == val.toLower())
            return static_cast<ETrackState>(e.keyToValue(e.key(k)));


    }

    return ETrackStateClass::LIVE;


}

ETrackStateClass::Value ETrackStateClass::getValueFromStringMapping(QString val)
{
    if (val.toLower() == "live")
        return ETrackState::LIVE;
    else if(val.toLower()=="stale")
        return ETrackState::STALE;
    else if(val.toLower()=="LOST")
        return ETrackState::LOST;

    return ETrackState::LIVE;
}

QString ETrackStateClass::getStringFromValue(ETrackStateClass::Value val)
{
    QMetaEnum e;
    e = QMetaEnum::fromType<ETrackState>();

    for (int k = 0; k < e.keyCount(); k++)
        if ((e.value(k) == val))
            return QString(e.key(k));

    return "";
}
