#ifndef ESERVICE_H
#define ESERVICE_H

#include <QObject>
#include <QtQml>

class EServiceStatusClass
{
    Q_GADGET

public:
    enum Value {
        CONNECTED=0,
        DISCONNECTED=1,
        CONNECTING=2,
        CLOSED=3,
        ACTIVE=4,
        UNKNOWN=-1
    };

    Q_ENUM(Value)

    static QList<QString> getAllValues();
    static QString getStringFromValue(EServiceStatusClass::Value val);
    static EServiceStatusClass::Value getValueFromString(QString val);
    static EServiceStatusClass::Value getValueFromStringMapping(QString val);

private:
    explicit EServiceStatusClass();
};

typedef EServiceStatusClass::Value EServiceStatus;

#endif // ESERVICE_H
