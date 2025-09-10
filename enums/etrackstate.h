#ifndef ETRACKSTATE_H
#define ETRACKSTATE_H
#include <QObject>
#include <QtQml>

class ETrackStateClass
{
    Q_GADGET
public:
    enum Value {
        LIVE=0,
        STALE=1,
        LOST=2
    };
    Q_ENUM(Value)

    static QList<QString> getAllValues();
    static QString getStringFromValue(ETrackStateClass::Value val);
    static ETrackStateClass::Value getValueFromString(QString val);
    static ETrackStateClass::Value getValueFromStringMapping(QString val);
private:
    explicit ETrackStateClass();


};

typedef ETrackStateClass::Value ETrackState;

#endif // ETRACKSTATE_H
